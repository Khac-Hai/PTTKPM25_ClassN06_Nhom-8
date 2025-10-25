# main.py
import os
import math
import datetime as dt
from pathlib import Path
from typing import Optional, Dict, Any, List

import pandas as pd
import httpx
from dotenv import load_dotenv
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import create_engine, text

# ===================== ENV =====================
load_dotenv()
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
GEMINI_MODEL = os.getenv("GEMINI_MODEL", "gemini-1.5-flash")

# ===================== APP & CORS =====================
app = FastAPI(title="Finance Coach API (Gemini)")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # production: thay bằng domain của bạn
    allow_methods=["*"],
    allow_headers=["*"],
)

# ===================== DB ENGINE (SQLite an toàn) =====================
# Ưu tiên DATABASE_URL từ .env; nếu không có, rơi về ./demo.db (cùng thư mục file)
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    db_path = Path(__file__).parent / "demo.db"
    db_path.parent.mkdir(parents=True, exist_ok=True)
    DATABASE_URL = f"sqlite:///{db_path.as_posix()}"

# SQLite cần connect_args; DB khác (Postgres/MySQL) để {}.
connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}

engine = create_engine(
    DATABASE_URL,
    connect_args=connect_args,
    pool_pre_ping=True,
    future=True,
)

# ===================== SCHEMAS =====================
class ChatReq(BaseModel):
    user_id: str
    message: str

class ChatRes(BaseModel):
    reply: str

# ===================== HELPERS =====================
def read_user_df(user_id: str) -> pd.DataFrame:
    """Đọc giao dịch của user thành DataFrame."""
    with engine.connect() as conn:
        df = pd.read_sql(
            "SELECT * FROM transactions WHERE user_id = :u",
            conn,
            params={"u": user_id},
        )
    if df.empty:
        df = pd.DataFrame(
            columns=["id", "user_id", "date", "amount", "category", "note", "type"]
        )
    df["date"] = pd.to_datetime(df["date"], errors="coerce")
    return df

def month_key(d: dt.date) -> str:
    return f"{d.year}-{d.month:02d}"

def month_summary(df: pd.DataFrame, month: Optional[str] = None) -> Dict[str, Any]:
    """Tính tổng quan chi/thu theo tháng, top category, outliers, tiến độ thời gian."""
    if month is None:
        month = month_key(dt.date.today())
    p = pd.Period(month)

    cur = df[df["date"].dt.to_period("M") == p]
    prev = df[df["date"].dt.to_period("M") == p - 1]

    total_exp = float(cur[cur.type == "expense"]["amount"].sum())
    total_inc = float(cur[cur.type == "income"]["amount"].sum())
    prev_exp = float(prev[prev.type == "expense"]["amount"].sum() or 0.0)
    delta_pct = 0.0 if prev_exp == 0 else round(100 * (total_exp - prev_exp) / prev_exp, 1)

    by_cat = (
        cur[cur.type == "expense"]
        .groupby("category", dropna=False)["amount"]
        .sum()
        .sort_values(ascending=False)
        .head(5)
        .reset_index()
    )
    top_cats = [
        {"category": str(r["category"]), "amount": float(r["amount"])}
        for _, r in by_cat.iterrows()
    ]

    x = cur[cur.type == "expense"]["amount"]
    outliers: List[Dict[str, Any]] = []
    if len(x) >= 4:
        q1, q3 = x.quantile(0.25), x.quantile(0.75)
        iqr = q3 - q1
        outs = cur[(cur.type == "expense") & (cur.amount > q3 + 1.5 * iqr)]
        outliers = [
            {
                "date": str(r.date.date()),
                "amount": float(r.amount),
                "category": r.category,
                "note": r.note,
            }
            for _, r in outs.iterrows()
        ]

    today = dt.date.today()
    time_prog = today.day / pd.Period(today, "M").days_in_month

    return {
        "month": month,
        "total_expense": total_exp,
        "total_income": total_inc,
        "delta_pct": float(delta_pct),
        "top_cats": top_cats,
        "outliers": outliers,
        "time_progress": time_prog,
    }

def budget_progress(cur_expense: float, budget_limit: float, time_progress: float):
    if budget_limit <= 0:
        return None
    used = cur_expense / budget_limit
    warn = used > (time_progress + 0.10)  # tiêu nhanh hơn tốc độ thời gian > +10%
    return {
        "spent": cur_expense,
        "limit": budget_limit,
        "used_pct": used,
        "time_progress": time_progress,
        "warn": warn,
    }

def rule_based_advice(summary: Dict[str, Any], budgets: Dict[str, float]) -> str:
    lines: List[str] = []
    m = summary["month"]
    total = summary["total_expense"]
    inc = summary["total_income"]
    delta = summary["delta_pct"]

    lines.append(
        f"Tháng {m}, bạn đã chi ~ {total:,.0f}đ; thu ~ {inc:,.0f}đ (so với tháng trước: {delta:+.1f}%)."
    )

    if summary["top_cats"]:
        top = summary["top_cats"][0]
        lines.append(f"Danh mục tốn nhất: **{top['category']}** ~ {top['amount']:,.0f}đ.")

    if summary["outliers"]:
        o = summary["outliers"][0]
        lines.append(
            f"Có giao dịch bất thường {o['amount']:,.0f}đ ở {o['category']} ngày {o['date']}."
        )

    sugest: List[str] = []
    for cat, limit in budgets.items():
        spent = next(
            (c["amount"] for c in summary["top_cats"] if c["category"] == cat), 0.0
        )
        prog = budget_progress(spent, limit, summary["time_progress"])
        if prog and prog["warn"]:
            gap = math.ceil((prog["used_pct"] - summary["time_progress"]) * 100)
            save = max(0, int((spent - limit * summary["time_progress"])))
            sugest.append(
                f"- **{cat}** vượt tiến độ ~{gap}%. Gợi ý giảm ~{save:,.0f}đ trong 1–2 tuần tới."
            )
    if sugest:
        lines.append("Cảnh báo ngân sách:")
        lines.extend(sugest)

    if inc > 0 and total > 0:
        rate = (total / inc) * 100
        lines.append(f"Tỷ lệ chi/thu ≈ {rate:.0f}%. Hãy nhắm < 80% để còn phần tiết kiệm/đầu tư.")
    lines.append("Bạn muốn mình lập kế hoạch cắt giảm 3 mục tốn nhất tuần tới không?")
    return "\n".join(lines)

async def call_gemini(prompt_text: str) -> str:
    """Gọi Gemini. Nếu thiếu API key thì trả về prompt kèm lưu ý."""
    if not GEMINI_API_KEY:
        return "(Chưa cấu hình GEMINI_API_KEY). " + prompt_text

    url = (
        f"https://generativelanguage.googleapis.com/v1beta/models/"
        f"{GEMINI_MODEL}:generateContent?key={GEMINI_API_KEY}"
    )
    payload = {
        "contents": [{"role": "user", "parts": [{"text": prompt_text}]}],
        "generationConfig": {"temperature": 0.4},
    }
    async with httpx.AsyncClient(timeout=30) as client:
        r = await client.post(url, json=payload)
        r.raise_for_status()
        data = r.json()
        return data["candidates"][0]["content"]["parts"][0]["text"].strip()

# ===================== STARTUP: init schema + seed =====================
@app.on_event("startup")
def on_startup():
    # Nếu DATABASE_URL là sqlite file-based tuyệt đối, đảm bảo thư mục tồn tại
    if DATABASE_URL.startswith("sqlite:////"):
        # sqlite:////abs/path/to/db  -> /abs/path/to/db
        abs_path = DATABASE_URL.replace("sqlite:////", "/", 1)
        Path(abs_path).parent.mkdir(parents=True, exist_ok=True)

    with engine.begin() as conn:
        conn.exec_driver_sql(
            """
            CREATE TABLE IF NOT EXISTS transactions(
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                user_id TEXT, date TEXT, amount REAL,
                category TEXT, note TEXT, type TEXT
            );
            """
        )
        r = conn.execute(text("SELECT COUNT(*) FROM transactions")).scalar()
        if (r or 0) == 0:
            seed = [
                ("user_123", "2025-10-01", 90, "Ăn uống", "Bữa trưa", "expense"),
                ("user_123", "2025-10-02", 450, "Mua sắm", "Giày", "expense"),
                ("user_123", "2025-10-03", 1200, "Tiền nhà", "Tháng 10", "expense"),
                ("user_123", "2025-09-05", 1300, "Tiền nhà", "Tháng 9", "expense"),
                ("user_123", "2025-10-05", 50, "Giải trí", "Phim", "expense"),
                ("user_123", "2025-10-06", 1000, "Lương", "Lĩnh lương", "income"),
            ]
            conn.exec_driver_sql(
                "INSERT INTO transactions(user_id,date,amount,category,note,type) VALUES (?,?,?,?,?,?)",
                seed,
            )

# ===================== ROUTES =====================
@app.get("/health")
def health() -> Dict[str, bool]:
    return {"ok": True}

@app.post("/chat", response_model=ChatRes)
async def chat(req: ChatReq) -> ChatRes:
    df = read_user_df(req.user_id)
    s = month_summary(df)
    budgets = {
        "Ăn uống": 1500.0,
        "Mua sắm": 1000.0,
        "Giải trí": 500.0,
    }  # demo, có thể đọc từ DB

    context = rule_based_advice(s, budgets)
    prompt = (
        "Bạn là cố vấn tài chính cá nhân, trả lời TIẾNG VIỆT, gợi ý cụ thể theo số tiền.\n\n"
        f"NGỮ CẢNH:\n{context}\n\n"
        f"CÂU HỎI NGƯỜI DÙNG: {req.message}"
    )
    reply = await call_gemini(prompt)
    return ChatRes(reply=reply)

