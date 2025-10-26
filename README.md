# 💰 Quản Lý Chi Tiêu Cá Nhân (quan_ly_chi_tieu)

Ứng dụng di động **đa nền tảng (cross-platform)** được xây dựng bằng **Flutter**, giúp người dùng theo dõi, phân tích **thu nhập và chi tiêu cá nhân** một cách hiệu quả.
Ứng dụng sử dụng **Firebase** làm backend (cơ sở dữ liệu và xác thực người dùng).

> 📚 *Dự án này là Bài tập lớn cho môn học **Phân tích và Thiết kế Phần mềm.***

---

## 🖼️ Giao diện Ứng dụng

|                                                 Đăng nhập                                                 | Trang chủ (Dashboard) | Giao dịch & Lọc | Quản lý Ngân sách |
| :-------------------------------------------------------------------------------------------------------: | :-------------------: | :-------------: | :---------------: |
| <img width="423" height="842" alt="image" src="https://github.com/user-attachments/assets/81d4e4b2-bd6b-4a31-ab57-7a473410de05" />
 |        <img width="200" src="https://github.com/user-attachments/assets/4fd6418d-97c6-4f94-8dca-f011262674d6" />               |         <img width="421" height="844" alt="image" src="https://github.com/user-attachments/assets/77a5859c-810a-406f-81ac-5eeac6d4dd7f" />
        |         <img width="463" height="852" alt="image" src="https://github.com/user-attachments/assets/06138e66-8557-487a-adf3-753f1db69d8c" />
          |

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

| STT | Họ và Tên          | Mã sinh viên | GitHub                                 |
| :-: | :----------------- | :----------- | :------------------------------------- |
|  1  | **Vũ Huy Kỳ**      | 22010414     | [@Vuhuyky](https://github.com/Vuhuyky) |
|  2  | [Tên thành viên 2] | [Mã SV]      | [@username]                            |
|  3  | [Tên thành viên 3] | [Mã SV]      | [@username]                            |
|  4  | [Tên thành viên 4] | [Mã SV]      | [@username]                            |
|  5  | [Tên thành viên 5] | [Mã SV]      | [@username]                            |

---
---

## 📨 Liên hệ

* 🌐 GitHub Repository: [https://github.com/Khac-Hai/PTTKPM25_ClassN06_Nhom-8](https://github.com/Khac-Hai/PTTKPM25_ClassN06_Nhom-8)
