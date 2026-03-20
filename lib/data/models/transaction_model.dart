// Archivo: lib/data/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'expense' o 'income'
  final String category;
  final String merchantName; // En el MVP lo llamamos 'title'
  final DateTime date;
  final bool isRecurring;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.merchantName,
    required this.date,
    this.isRecurring = false,
    this.notes,
  });

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      // Mapeamos el booleano antiguo a los tipos formales de la arquitectura
      type: data['is_expense'] == true ? 'expense' : 'income',
      category: data['category'] ?? 'General',
      merchantName: data['title'] ?? 'Sin título',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRecurring: data['isRecurring'] ?? false,
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'is_expense': type == 'expense', // Mantenemos compatibilidad con el MVP
      'category': category,
      'title': merchantName,
      'date': Timestamp.fromDate(date),
      'isRecurring': isRecurring,
      'notes': notes,
    };
  }
}