import 'package:flutter/material.dart';
import 'package:quan_ly_chi_tieu/screens/add_trans.dart';
import 'package:quan_ly_chi_tieu/screens/transactions_screen.dart';
import 'home_screen.dart';
import 'budget_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // _selectedIndex: 0: Trang chủ, 1: Giao dịch, 2: (chỗ trống cho nút +), 3: Ngân sách, 4: Hồ sơ.
  int _selectedIndex = 0;

  // Danh sách các trang con (chỉ 4 trang – bỏ mục ở vị trí index 2 vì đó là chỗ dành cho nút “+”)
  final List<Widget> _screens = [
    const HomeScreen(),
    const TransactionScreen(),
    const BudgetScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Map _selectedIndex: nếu _selectedIndex < 2 thì dùng trực tiếp; nếu >= 3, thì dùng _selectedIndex - 1
    int screenIndex = _selectedIndex < 2 ? _selectedIndex : _selectedIndex - 1;

    return Scaffold(
      body: _screens[screenIndex],
      floatingActionButton: Container(
        height: 65,
        width: 65,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6E3AE3), Color(0xFF9B6DFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6E3AE3).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddTransactionScreen(),
              ),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white, // Nền trắng tinh
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.white, // Explicitly set background white
            currentIndex: _selectedIndex,
            onTap: (index) {
              // Nếu nhấn mục index 2 (dành cho nút “+”), không làm gì
              if (index == 2) return;
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF6E3AE3),
            unselectedItemColor: Colors.grey[400],
            showUnselectedLabels: true,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(fontSize: 12),
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home, 'Trang chủ', 0),
              _buildNavItem(
                Icons.receipt_long_outlined,
                Icons.receipt_long,
                'Giao dịch',
                1,
              ),
              const BottomNavigationBarItem(
                icon: SizedBox(height: 32),
                label: '',
              ),
              _buildNavItem(
                Icons.pie_chart_outline,
                Icons.pie_chart,
                'Ngân sách',
                3,
              ),
              _buildNavItem(Icons.person_outline, Icons.person, 'Hồ sơ', 4),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    bool isSelected = _selectedIndex == index;
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color(0xFF6E3AE3).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? const Color(0xFF6E3AE3) : Colors.grey[400],
          size: 24,
        ),
      ),
      label: label,
    );
  }
}
