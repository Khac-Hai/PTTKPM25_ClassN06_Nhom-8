import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quan_ly_chi_tieu/auth/login_screen.dart';
import 'my.dart';
import 'cai_dat_screen.dart';
import 'xuat_du_lieu_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Ảnh đại diện + tên + email
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[200],
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? const Icon(Icons.person, size: 50, color: Colors.grey)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(
                user?.displayName ?? "Người dùng",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                user?.email ?? "Chưa có email",
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 30),

              // Menu
              _buildMenuItem(
                icon: Icons.person,
                title: 'Về của tôi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const VeCuaToiScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.settings,
                title: 'Cài đặt',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CaiDatScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.download,
                title: 'Xuất dữ liệu',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const XuatDuLieuScreen()),
                  );
                },
              ),
              _buildMenuItem(
                icon: Icons.logout,
                title: 'Đăng xuất',
                isDestructive: true,
                onTap: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    bool isDestructive = false,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : Colors.purple),
        title: Text(
          title,
          style: TextStyle(
            color: isDestructive ? Colors.red : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
