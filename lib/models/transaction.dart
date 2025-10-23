import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String userId;
  final String type; // 'income' hoặc 'expense'
  final double amount;
  final String category;
  final String description;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    required this.date,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? 'expense',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? 'Khác',
      description: data['description'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}
