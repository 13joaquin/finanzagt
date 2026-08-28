// Archivo: lib/data/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String type;
  final String category;
  final bool isFixed; // <-- NUEVO: Para saber si es gasto fijo

  TransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.isFixed = false, // <-- Por defecto es falso
  });

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type,
      'category': category,
      'isFixed': isFixed, // <-- Guardamos la propiedad
    };
  }

  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      parsedDate = DateTime.tryParse(data['date']) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return TransactionModel(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: parsedDate,
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'General',
      isFixed: data['isFixed'] ?? false, // <-- Leemos la propiedad
    );
  }
}