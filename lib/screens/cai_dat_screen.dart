import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/main.dart';

class CaiDatScreen extends StatefulWidget {
  const CaiDatScreen({super.key});

  @override
  State<CaiDatScreen> createState() => _CaiDatScreenState();
}

class _CaiDatScreenState extends State<CaiDatScreen> {
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Chế độ tối'),
            value: _darkMode,
            onChanged: (value) {
              setState(() => _darkMode = value);
              MyApp.of(context)?.toggleTheme(value);
            },
          ),
          ListTile(
            title: const Text('Ngôn ngữ'),
            subtitle: const Text('Tiếng Việt'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tính năng đang phát triển...')),
              );
            },
          ),
        ],
      ),
    );
  }
}
