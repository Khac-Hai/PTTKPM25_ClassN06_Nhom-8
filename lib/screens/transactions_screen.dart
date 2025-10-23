import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_chi_tieu/models/transaction.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen({Key? key}) : super(key: key);

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final user = FirebaseAuth.instance.currentUser;

  // Dropdown chọn tháng/năm (nếu cần lọc)
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Bạn chưa đăng nhập")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Giao dịch")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Nếu cần, có thể thêm dropdown chọn tháng/năm ở đây
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<int>(
                  value: _selectedMonth,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedMonth = val);
                    }
                  },
                  items: List.generate(12, (index) {
                    final month = index + 1;
                    return DropdownMenuItem(
                      value: month,
                      child: Text(
                        DateFormat.MMMM().format(DateTime(2000, month)),
                      ),
                    );
                  }),
                ),
                DropdownButton<int>(
                  value: _selectedYear,
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedYear = val);
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
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance
                        .collection("transactions")
                        .where("userId", isEqualTo: user!.uid)
                        .where("year", isEqualTo: _selectedYear)
                        .where("month", isEqualTo: _selectedMonth)
                        // Nếu dùng orderBy("date"), bạn cần tạo composite index
                        // .orderBy("date", descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text("Lỗi: ${snapshot.error}"));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text("Không có giao dịch"));
                  }

                  // Chuyển dữ liệu Firestore -> List<TransactionModel>
                  final allTransactions =
                      snapshot.data!.docs
                          .map((doc) => TransactionModel.fromFirestore(doc))
                          .toList();

                  // Sắp xếp cục bộ theo date giảm dần
                  allTransactions.sort((a, b) => b.date.compareTo(a.date));

                  // Tách thành 2 danh sách: expense và income
                  final expenseList =
                      allTransactions
                          .where((t) => t.type == 'expense')
                          .toList();
                  final incomeList =
                      allTransactions.where((t) => t.type == 'income').toList();

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Xem báo cáo tài chính của bạn",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Khoản Chi",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: expenseList.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionItem(
                              expenseList[index],
                              isExpense: true,
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Thu nhập",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: incomeList.length,
                          itemBuilder: (context, index) {
                            return _buildTransactionItem(
                              incomeList[index],
                              isExpense: false,
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Hàm xây dựng 1 item giao dịch
  Widget _buildTransactionItem(TransactionModel t, {required bool isExpense}) {
    final iconBgColor = isExpense ? Colors.red[50] : Colors.green[50];
    final iconColor = isExpense ? Colors.red : Colors.green;
    final sign = isExpense ? "-" : "+";
    final amountColor = isExpense ? Colors.red : Colors.green;

    final timeString = DateFormat.jm().format(t.date);
    // Nếu mô tả rỗng, thay bằng ngày (định dạng dd/MM)
    final subtitle =
        t.description.isNotEmpty
            ? t.description
            : DateFormat('dd/MM').format(t.date);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icon + nền
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isExpense ? Icons.shopping_bag : Icons.attach_money,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          // Danh mục + mô tả
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          // Số tiền + giờ
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "$sign\$${t.amount.toStringAsFixed(0)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              Text(
                timeString,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
