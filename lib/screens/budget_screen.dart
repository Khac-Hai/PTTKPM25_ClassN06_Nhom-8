import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../models/expense_data.dart';
import '../widgets/animated_pie_chart.dart';
import '../services/transaction_service.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  bool isExpense =
      true; // true: hiển thị "khoản chi", false: hiển thị "thu nhập"

  // Dữ liệu cho biểu đồ
  List<ExpenseData> _expenseData = [];
  List<ExpenseData> _incomeData = [];

  double _totalExpense = 0;
  double _totalIncome = 0;

  bool _isLoading = false;

  // Dropdown chọn tháng, năm
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() => _isLoading = true);
    try {
      // Dùng hàm getTransactionsByMonth từ TransactionService
      final transactionsStream = TransactionService.getTransactionsByMonth(
        _selectedMonth,
        _selectedYear,
      );

      // Lắng nghe dữ liệu một lần (hoặc dùng StreamBuilder nếu muốn realtime)
      final querySnapshot = await transactionsStream.first;

      // Tạo map để nhóm theo danh mục
      final Map<String, double> expenseByCategory = {};
      final Map<String, double> incomeByCategory = {};

      double totalExpense = 0;
      double totalIncome = 0;

      for (var t in querySnapshot) {
        // Sử dụng t.type, t.amount, t.category từ TransactionModel
        if (t.type == 'expense') {
          totalExpense += t.amount;
          expenseByCategory[t.category] =
              (expenseByCategory[t.category] ?? 0) + t.amount;
        } else {
          totalIncome += t.amount;
          incomeByCategory[t.category] =
              (incomeByCategory[t.category] ?? 0) + t.amount;
        }
      }

      final rng = Random();
      List<ExpenseData> expenseList =
          expenseByCategory.entries.map((entry) {
            return ExpenseData(entry.key, entry.value, _getRandomColor(rng));
          }).toList();

      List<ExpenseData> incomeList =
          incomeByCategory.entries.map((entry) {
            return ExpenseData(entry.key, entry.value, _getRandomColor(rng));
          }).toList();

      setState(() {
        _expenseData = expenseList;
        _incomeData = incomeList;
        _totalExpense = totalExpense;
        _totalIncome = totalIncome;
      });
    } catch (e) {
      print("Lỗi khi lấy dữ liệu Firestore: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Color _getRandomColor(Random rng) {
    return Color.fromRGBO(
      rng.nextInt(256),
      rng.nextInt(256),
      rng.nextInt(256),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Báo cáo tài chính',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Dropdown chọn tháng, năm
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          DropdownButton<int>(
                            value: _selectedMonth,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedMonth = val);
                                _fetchTransactions();
                              }
                            },
                            items: List.generate(12, (index) {
                              final month = index + 1;
                              return DropdownMenuItem(
                                value: month,
                                child: Text(
                                  DateFormat.MMMM().format(
                                    DateTime(2000, month),
                                  ),
                                ),
                              );
                            }),
                          ),
                          DropdownButton<int>(
                            value: _selectedYear,
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedYear = val);
                                _fetchTransactions();
                              }
                            },
                            items: List.generate(5, (index) {
                              final year = DateTime.now().year - 2 + index;
                              return DropdownMenuItem(
                                value: year,
                                child: Text(year.toString()),
                              );
                            }),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTypeToggle(),
                      const SizedBox(height: 30),
                      // Biểu đồ tròn
                      Center(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                spreadRadius: 0,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              AnimatedPieChart(
                                data: isExpense ? _expenseData : _incomeData,
                                size: 200,
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isExpense
                                        ? '\$${_totalExpense.toStringAsFixed(0)}'
                                        : '\$${_totalIncome.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isExpense ? 'Chi tiêu' : 'Thu nhập',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Danh sách giao dịch
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 30),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Loại',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.filter_list),
                                    onPressed: () {
                                      // Bổ sung filter nếu cần
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children:
                                        isExpense
                                            ? _expenseData
                                                .map(_buildExpenseItem)
                                                .toList()
                                            : _incomeData
                                                .map(_buildIncomeItem)
                                                .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }

  // Toggle "Khoản chi" / "Thu nhập"
  Widget _buildTypeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExpense = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      isExpense ? const Color(0xFF6E3AE3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow:
                      isExpense
                          ? [
                            BoxShadow(
                              color: const Color(0xFF6E3AE3).withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    'Khoản chi',
                    style: TextStyle(
                      color: isExpense ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isExpense = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color:
                      !isExpense ? const Color(0xFF6E3AE3) : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow:
                      !isExpense
                          ? [
                            BoxShadow(
                              color: const Color(0xFF6E3AE3).withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                          : null,
                ),
                child: Center(
                  child: Text(
                    'Thu nhập',
                    style: TextStyle(
                      color: !isExpense ? Colors.white : Colors.black54,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị item chi tiêu
  Widget _buildExpenseItem(ExpenseData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.category,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '- \$${data.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _totalExpense == 0 ? 0 : data.amount / _totalExpense,
            backgroundColor: data.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(data.color),
          ),
        ],
      ),
    );
  }

  // Hiển thị item thu nhập
  Widget _buildIncomeItem(ExpenseData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  data.category,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '+ \$${data.amount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _totalIncome == 0 ? 0 : data.amount / _totalIncome,
            backgroundColor: data.color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(data.color),
          ),
        ],
      ),
    );
  }
}
