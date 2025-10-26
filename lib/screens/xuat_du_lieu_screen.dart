import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class XuatDuLieuScreen extends StatelessWidget {
  const XuatDuLieuScreen({super.key});

  /// 🔹 Lấy dữ liệu từ Firestore
  Future<List<Map<String, dynamic>>> layDuLieuFirebase() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('transactions').get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  /// 🔹 Xuất dữ liệu ra file CSV (lưu vào thư mục Download)
  Future<String> xuatFileCSV(List<Map<String, dynamic>> data) async {
    if (data.isEmpty) {
      throw Exception('Không có dữ liệu để xuất!');
    }

    // 🔸 Tạo dữ liệu CSV
    List<List<dynamic>> csvData = [];
    csvData.add(data.first.keys.toList()); // Dòng tiêu đề
    for (var row in data) {
      csvData.add(row.values.toList());
    }

    final csv = const ListToCsvConverter().convert(csvData);

    // 🔸 Lưu file CSV vào thư mục Download (dễ tìm trong emulator)
    final Directory dir = Directory('/storage/emulated/0/Download');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }

    final String filePath = '${dir.path}/dulieu_chitieu.csv';
    final file = File(filePath);
    await file.writeAsString(csv);

    return filePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xuất dữ liệu Firebase'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            try {
              // 🔹 Bước 1: Lấy dữ liệu từ Firebase
              final data = await layDuLieuFirebase();

              // 🔹 Bước 2: Xuất ra file CSV
              final filePath = await xuatFileCSV(data);

              // 🔹 Hiển thị thông báo
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content:
                      Text('✅ Xuất dữ liệu thành công!\nLưu tại: $filePath'),
                  duration: const Duration(seconds: 5),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ Lỗi khi xuất dữ liệu: $e'),
                  duration: const Duration(seconds: 4),
                ),
              );
            }
          },
          icon: const Icon(Icons.download),
          label: const Text('Xuất dữ liệu Firebase sang CSV'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ),
    );
  }
}
