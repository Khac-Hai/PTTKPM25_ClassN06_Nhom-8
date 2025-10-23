import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BudgetService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Thiết lập hoặc cập nhật ngân sách cho một danh mục
  static Future<void> setBudget({
    required String category,
    required double budgetAmount,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User is not logged in");
    }

    await _firestore.collection("budgets").doc("${user.uid}_$category").set({
      'userId': user.uid,
      'category': category,
      'budgetAmount': budgetAmount,
      'updatedAt': Timestamp.now(),
    });
  }
}
