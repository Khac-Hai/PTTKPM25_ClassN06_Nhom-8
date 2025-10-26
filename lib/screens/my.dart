import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VeCuaToiScreen extends StatefulWidget {
  const VeCuaToiScreen({super.key});

  @override
  State<VeCuaToiScreen> createState() => _VeCuaToiScreenState();
}

class _VeCuaToiScreenState extends State<VeCuaToiScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final _nameController = TextEditingController();
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';
  }

  Future<void> _updateProfile() async {
    setState(() => _isSaving = true);
    try {
      await user?.updateDisplayName(_nameController.text);
      await user?.reload();
      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật thông tin thành công!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Về của tôi'),
        backgroundColor: Colors.purple,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child: user?.photoURL == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 16),
            _isEditing
                ? TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Tên hiển thị',
                      border: OutlineInputBorder(),
                    ),
                  )
                : Text(
                    user?.displayName ?? 'Người dùng',
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
            const SizedBox(height: 12),
            Text(user?.email ?? 'Chưa có email'),
            const SizedBox(height: 30),

            // Nút Lưu khi đang chỉnh sửa
            if (_isEditing)
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _updateProfile,
                icon: const Icon(Icons.save),
                label: const Text('Lưu thay đổi'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
