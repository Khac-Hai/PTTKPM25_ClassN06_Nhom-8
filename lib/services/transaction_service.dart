import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quan_ly_chi_tieu/models/transaction.dart';

class TransactionService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Thêm giao dịch vào Firestore, lưu thêm "year" và "month" để dễ lọc
  static Future<void> addTransaction({
    required String type, // 'income' hoặc 'expense'
    required double amount,
    required String category,
    required DateTime date,
    required String description,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in");
    }
    await _db.collection("transactions").add({
      'userId': user.uid,
      'type': type,
      'amount': amount,
      'category': category,
      'date': Timestamp.fromDate(date),
      'year': date.year, // lưu năm của giao dịch
      'month': date.month, // lưu tháng của giao dịch
      'description': description,
      'createdAt': Timestamp.now(),
    });
  }

  /// Lấy danh sách giao dịch theo tháng và năm
  static Stream<List<TransactionModel>> getTransactionsByMonth(
    int month,
    int year,
  ) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('transactions')
        .where('userId', isEqualTo: user.uid)
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => TransactionModel.fromFirestore(doc))
                  .toList(),
        );
  }
}
