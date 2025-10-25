import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../screens/main_screen.dart';

class FacebookSignInButton extends StatelessWidget {
  const FacebookSignInButton({super.key});

  Future<void> signInWithFacebook(BuildContext context) async {
    try {
      // 1️⃣ Đăng nhập bằng Facebook SDK
      final LoginResult result = await FacebookAuth.instance.login();

      // Kiểm tra xem widget còn mounted không
      if (!context.mounted) return;

      if (result.status == LoginStatus.success) {
        // 2️⃣ Lấy access token từ Facebook
        final AccessToken accessToken = result.accessToken!;

        // 3️⃣ Tạo credential để đăng nhập Firebase (sửa ở đây)
        final facebookAuthCredential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        // 4️⃣ Đăng nhập vào Firebase bằng credential
        await FirebaseAuth.instance
            .signInWithCredential(facebookAuthCredential);

        // Kiểm tra lại mounted trước khi điều hướng
        if (!context.mounted) return;

        // 5️⃣ Điều hướng sang MainScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } else if (result.status == LoginStatus.cancelled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Bạn đã huỷ đăng nhập Facebook.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi đăng nhập Facebook: ${result.message}")),
        );
      }
    } catch (e) {
      // Xử lý lỗi tổng quát
      debugPrint("Đăng nhập Facebook thất bại: $e");

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Đăng nhập Facebook thất bại: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => signInWithFacebook(context),
      icon: Image.asset(
        'assets/icons/facebook-icon.png',
        height: 24,
        width: 24,
      ),
      label: const Text("Đăng nhập bằng Facebook"),
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
