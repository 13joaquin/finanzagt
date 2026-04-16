// Archivo: lib/data/models/expense_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String category;
  final bool isFixed; // TRUE para Gastos Fijos, FALSE para Flexibles

  ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.category,
    required this.isFixed,
  });

  factory ExpenseModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return ExpenseModel(
      id: doc.id,
      name: data['name'] ?? 'Gasto sin nombre',
      amount: (data['amount'] ?? 0).toDouble(),
      // Manejo seguro de fechas desde Firebase Timestamp
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      category: data['category'] ?? 'General',
      isFixed: data['is_fixed'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'category': category,
      'is_fixed': isFixed,
    };
  }
}