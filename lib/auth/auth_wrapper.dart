import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import 'login_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Đang chờ thông tin đăng nhập
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // Chưa đăng nhập
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }
        // Đã đăng nhập, kiểm tra emailVerified
        final user = snapshot.data!;
        if (!user.emailVerified) {
          // Chưa xác nhận email -> quay về LoginScreen (nơi hiển thị lỗi)
          return const LoginScreen();
        }
        // Đã xác nhận email -> vào MainScreen
        return const MainScreen();
      },
    );
  }
}
