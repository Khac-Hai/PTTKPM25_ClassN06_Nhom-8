# 💰 Quản Lý Chi Tiêu Cá Nhân (quan_ly_chi_tieu)

Ứng dụng di động **đa nền tảng (cross-platform)** được xây dựng bằng **Flutter**, giúp người dùng theo dõi, phân tích **thu nhập và chi tiêu cá nhân** một cách hiệu quả.
Ứng dụng sử dụng **Firebase** làm backend (cơ sở dữ liệu và xác thực người dùng).

> 📚 *Dự án này là Bài tập lớn cho môn học **Phân tích và Thiết kế Phần mềm.***

---

## 📱 Giao diện Ứng dụng

### 🔐 Màn hình Đăng nhập
<img width="423" height="842" alt="Screenshot 2025-10-26 131739" src="https://github.com/user-attachments/assets/b3dbcef2-6831-4223-8d9d-ecd77931ccdf" />


---

### 🏠 Trang chủ (Dashboard)
<img width="430" height="840" alt="Screenshot 2025-10-26 131159" src="https://github.com/user-attachments/assets/41fa8117-7634-46e8-a955-43ccf11541e0" />


---

### 💰 Giao dịch & Lọc
<img width="421" height="844" alt="Screenshot 2025-10-26 131940" src="https://github.com/user-attachments/assets/245aa604-642e-40be-a372-5ed08b7acb89" />


---

### 🎯 Quản lý Ngân sách
<img width="463" height="852" alt="Screenshot 2025-10-26 132005" src="https://github.com/user-attachments/assets/80e4b1c8-b67e-4270-a22e-48689c1c2202" />



---

## ✨ Tính năng Nổi bật

### 🔐 Xác thực Người dùng

* Đăng ký và Đăng nhập bằng **Email / Mật khẩu**
* Đăng nhập nhanh bằng **Google (Google Sign-In)**
* Hỗ trợ tính năng **“Quên mật khẩu”**

### 💸 Quản lý Giao dịch

* Thêm mới các khoản **Thu nhập (Income)** và **Chi tiêu (Expense)**
* Phân loại giao dịch theo **danh mục** (Ăn uống, Di chuyển, Mua sắm, …)
* Xem **lịch sử giao dịch chi tiết**

### 📊 Bảng điều khiển (Dashboard)

* Hiển thị **tổng quan số dư, tổng thu, tổng chi**
* Biểu đồ đường (**Line Chart**) phân tích chi tiêu theo thời gian
* Danh sách các giao dịch gần đây

### 🔎 Phân tích & Lọc

* Biểu đồ tròn (**Pie Chart**) trực quan tỷ lệ chi tiêu theo danh mục
* **Bộ lọc mạnh mẽ:** Lọc giao dịch theo *Tháng*, *Năm* hoặc *Danh mục* cụ thể

### 💼 Quản lý Ngân sách

* Đặt **ngân sách (budget)** cho từng danh mục
* Cảnh báo khi sắp vượt ngân sách

### 👤 Cá nhân hóa

* Quản lý thông tin **hồ sơ người dùng (Profile)**
* Hỗ trợ **Giao diện Sáng/Tối (Light/Dark Mode)**

---

## 🛠️ Công nghệ Sử dụng

| Thành phần         | Công nghệ            | Mô tả                                  |
| ------------------ | -------------------- | -------------------------------------- |
| **Frontend**       | Flutter (Dart)       | Xây dựng giao diện và logic người dùng |
| **Backend**        | Firebase             | Lưu trữ, xác thực, xử lý dữ liệu       |
| **Database**       | Firestore            | Lưu thông tin giao dịch, ngân sách...  |
| **Authentication** | Firebase Auth        | Đăng nhập qua Email và Google          |
| **Thư viện**       | fl_chart             | Biểu đồ tròn và đường                  |
|                    | intl                 | Định dạng ngày, tiền tệ                |
|                    | font_awesome_flutter | Bộ icon phong phú                      |
|                    | device_preview       | Xem giao diện trên nhiều thiết bị      |

---

## ⚙️ Cài đặt và Chạy Dự án

### 1️⃣ Clone Repository

```bash
git clone https://github.com/Khac-Hai/PTTKPM25_ClassN06_Nhom-8.git
cd quan_ly_chi_tieu
```

### 2️⃣ Lấy các Gói Flutter

```bash
flutter pub get
```

---

## 🔥 Kết nối Firebase (Rất quan trọng)

Dự án này sử dụng file `firebase_options.dart` (đã nằm trong `.gitignore`).
Bạn cần **tự kết nối dự án Flutter với Firebase** của mình theo các bước sau:

### 🔧 Bước 1. Tạo Dự án Firebase

Truy cập [Firebase Console](https://console.firebase.google.com/) → tạo dự án mới.

### 🔧 Bước 2. Kích hoạt các dịch vụ

* **Authentication:** bật đăng nhập bằng *Email/Mật khẩu* và *Google*
* **Firestore Database:** tạo cơ sở dữ liệu Firestore

### 🔧 Bước 3. Cài đặt FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

### 🔧 Bước 4. Cấu hình Firebase cho dự án

```bash
flutterfire configure
```

> Làm theo hướng dẫn trên terminal và chọn đúng dự án Firebase bạn vừa tạo.
> Lệnh này sẽ tự động sinh ra file `firebase_options.dart`.

---

## ▶️ Chạy Ứng dụng

```bash
flutter run
```

---

## 👨‍💻 Đội ngũ Phát triển

Dự án được hoàn thành bởi **Nhóm [Tên Nhóm] – [Tên Lớp]:**

| STT | Họ và Tên              | Mã sinh viên | GitHub                                                          |
| :-: | :----------------------| :----------- | :---------------------------------------------------------------|
|  1  | **Vũ Huy Kỳ**          | 22010414     | [@Vuhuyky](https://github.com/Vuhuyky)                          |
|  2  | **Nguyễn Khắc Hải**    | 22010460     | [@Khac-Hai](https://github.com/Khac-Hai)                        |
|  3  | **Nguyễn Hoàng Giang** | 22010370     | [@BlooDDonorGiangHoang](https://github.com/BlooDDonorGiangHoang)|
|  4  | **Nguyễn Vũ Minh Thư** | 22010405     | [@nvmthu](https://github.com/nvmthu)                            |
|  5  | **Lê Phi Yến**         | 22010423     | [@yenle254](https://github.com/yenle254)                        |

---
---

## 📨 Liên hệ

* 🌐 GitHub Repository: [https://github.com/Khac-Hai/PTTKPM25_ClassN06_Nhom-8](https://github.com/Khac-Hai/PTTKPM25_ClassN06_Nhom-8)
