Dự án Quản Lý Chi Tiêu Cá Nhân (quan_ly_chi_tieu)

Đây là một ứng dụng di động đa nền tảng (cross-platform) được xây dựng bằng Flutter, giúp người dùng theo dõi, phân tích thu nhập và chi tiêu cá nhân một cách hiệu quả. Ứng dụng này sử dụng Firebase làm backend (cơ sở dữ liệu, xác thực).

Dự án này là Bài tập lớn cho môn học Phân tích và Thiết kế Phần mềm.

<img width="430" height="840" alt="image" src="https://github.com/user-attachments/assets/4fd6418d-97c6-4f94-8dca-f011262674d6" />


Đăng nhập

Trang chủ (Dashboard)





Giao dịch & Lọc

Quản lý Ngân sách





✨ Tính năng Nổi bật

Xác thực Người dùng:

Đăng ký và Đăng nhập bằng Email/Mật khẩu.

Đăng nhập nhanh bằng tài khoản Google (Google Sign-In).

Chức năng "Quên mật khẩu".

Quản lý Giao dịch:

Thêm mới các khoản Thu nhập (Income) và Chi tiêu (Expense).

Phân loại giao dịch theo danh mục (Ăn uống, Di chuyển, Mua sắm...).

Xem lịch sử giao dịch chi tiết.

Bảng điều khiển (Dashboard):

Hiển thị tổng quan số dư, tổng thu, tổng chi.

Biểu đồ đường (Line Chart) phân tích chi tiêu theo thời gian.

Danh sách các giao dịch gần đây.

Phân tích & Lọc:

Biểu đồ tròn (Pie Chart) trực quan hóa tỷ lệ chi tiêu theo danh mục.

Bộ lọc mạnh mẽ: Lọc danh sách giao dịch theo Tháng, Năm và theo Danh mục cụ thể.

Quản lý Ngân sách:

Cho phép người dùng đặt ngân sách (budget) cho từng danh mục.

Cá nhân hóa:

Quản lý thông tin hồ sơ (Profile).

Hỗ trợ giao diện Sáng/Tối (Light/Dark Mode).

🚀 Công nghệ sử dụng

Frontend: Flutter (Dart)

Backend & Cơ sở dữ liệu: Firebase

Firestore: Lưu trữ dữ liệu giao dịch, ngân sách...

Authentication: Xử lý đăng nhập (Email, Google).

Thư viện Flutter nổi bật:

fl_chart: Vẽ biểu đồ đường và biểu đồ tròn.

intl: Định dạng ngày tháng và tiền tệ.

font_awesome_flutter: Bộ icon phong phú.

device_preview: Giúp kiểm tra giao diện trên nhiều thiết bị.

👨‍💻 Đội ngũ Phát triển

Dự án này được hoàn thành bởi Nhóm [Tên Nhóm] - [Tên Lớp]:

STT

Họ và Tên

Mã sinh viên

GitHub

1

Vũ Huy Kỳ 

22010414

@Vuhuyky

2

[Tên thành viên 2]

[Mã SV]

[@username]

3

[Tên thành viên 3]

[Mã SV]

[@username]

4

[Tên thành viên 4]

[Mã SV]

[@username]

5

[Tên thành viên 5]

[Mã SV]

[@username]

(Phần "Tác giả" dưới đây bị trùng lặp, bạn có thể xóa đi nếu đã có tên ở bảng trên)

🏁 Cài đặt và Chạy dự án

Để chạy dự án này trên máy của bạn, hãy làm theo các bước sau:

1. Clone Repository

git clone https://github.com/Khac-Hai/PTTKPM25_ClassN06_Nhom-8.git
cd quan_ly_chi_tieu


2. Lấy các Gói Flutter

flutter pub get


3. Kết nối với Firebase (Rất quan trọng)

Dự án này sử dụng file firebase_options.dart đã được đưa vào .gitignore. Bạn cần kết nối dự án này với dự án Firebase của riêng bạn.

Tạo một dự án mới trên Firebase Console.

Trong dự án của bạn, kích hoạt các dịch vụ sau:

Authentication: Bật phương thức Đăng nhập bằng Email/Mật khẩu và Google.

Firestore Database: Tạo cơ sở dữ liệu Firestore.

Cài đặt FlutterFire CLI (nếu chưa có):

dart pub global activate flutterfire_cli


Chạy lệnh configure để tự động kết nối và tạo file firebase_options.dart:

flutterfire configure


(Làm theo hướng dẫn trên terminal, chọn đúng dự án Firebase bạn vừa tạo).

4. Chạy Ứng dụng

flutter run

