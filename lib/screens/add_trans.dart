import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/transaction_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  String _transactionType = 'expense'; // 'expense' hoặc 'income'
  String _category = '';
  String _description = '';
  double _amount = 0;
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;

  // Hàm chọn ngày giao dịch
  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Kiểm tra xem nếu là khoản chi thì tổng chi tiêu (cũ + mới)
  /// có vượt quá tổng thu nhập hiện có hay không.
  Future<bool> _canAffordExpense(double expenseAmount) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Lấy tất cả giao dịch của user (không lọc theo tháng; tính tổng toàn bộ)
    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('transactions')
            .where('userId', isEqualTo: user.uid)
            .get();

    double totalIncome = 0;
    double totalExpense = 0;
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final type = data['type'] ?? 'expense';
      final amt = (data['amount'] ?? 0).toDouble();
      if (type == 'income') {
        totalIncome += amt;
      } else {
        totalExpense += amt;
      }
    }
    // Kiểm tra tổng chi sau khi thêm giao dịch mới
    return (totalExpense + expenseAmount) <= totalIncome;
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    // Nếu giao dịch là khoản chi, kiểm tra tổng thu nhập
    if (_transactionType == 'expense') {
      bool canAfford = await _canAffordExpense(_amount);
      if (!canAfford) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Không thể chi vượt quá tổng thu nhập hiện có!"),
          ),
        );
        return; // Dừng, không lưu giao dịch
      }
    }

    setState(() => _isLoading = true);
    try {
      await TransactionService.addTransaction(
        type: _transactionType,
        amount: _amount,
        category: _category,
        date: _selectedDate,
        description: _description,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giao dịch đã được thêm thành công")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi thêm giao dịch: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Thêm giao dịch")),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Loại giao dịch",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Khoản chi"),
                        selected: _transactionType == 'expense',
                        onSelected: (selected) {
                          setState(() {
                            _transactionType = 'expense';
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text("Thu nhập"),
                        selected: _transactionType == 'income',
                        onSelected: (selected) {
                          setState(() {
                            _transactionType = 'income';
                          });
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Số tiền",
                    hintText: "Nhập số tiền",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập số tiền";
                    }
                    final num? amt = num.tryParse(value);
                    if (amt == null || amt <= 0) {
                      return "Số tiền không hợp lệ";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _amount = double.parse(value!.trim());
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Danh mục",
                    hintText: "Ví dụ: Ăn uống, Mua sắm, Lương...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Vui lòng nhập danh mục";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _category = value!.trim();
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Ngày: ${_selectedDate.toLocal().toString().split(' ')[0]}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton(
                      onPressed: _pickDate,
                      child: const Text("Chọn ngày"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: "Mô tả",
                    hintText: "Nhập mô tả giao dịch",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: 3,
                  onSaved: (value) {
                    _description = value?.trim() ?? "";
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                      onPressed: _submitTransaction,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Lưu giao dịch"),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
