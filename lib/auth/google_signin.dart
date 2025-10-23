import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  Future<void> signInWithGoogle() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      await FirebaseAuth.instance.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      debugPrint("Google sign-in failed: ${e.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: signInWithGoogle,
      icon: Image.asset(
        'assets/icons/google-icon.png', // Đảm bảo hình ảnh này có trong thư mục assets và khai báo trong pubspec.yaml
        height: 24,
        width: 24,
      ),
      label: const Text("Đăng nhập bằng Google"),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black54,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
