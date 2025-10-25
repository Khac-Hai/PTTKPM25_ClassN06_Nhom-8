import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../screens/main_screen.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    try {
      // 1️⃣ Hiển thị hộp chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        // Người dùng hủy đăng nhập
        return;
      }

      // 2️⃣ Lấy thông tin xác thực từ Google
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3️⃣ Tạo credential để đăng nhập Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4️⃣ Đăng nhập vào Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // 5️⃣ Chuyển đến màn hình chính
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } catch (e) {
      debugPrint("Lỗi đăng nhập Google: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập Google thất bại: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => signInWithGoogle(context),
      icon: Image.asset(
        'assets/icons/google-icon.png', // Đảm bảo icon có trong thư mục assets
        height: 24,
        width: 24,
      ),
      label: const Text(
        "Đăng nhập bằng Google",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
