// Ubicación: lib/data/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'expense' o 'income'
  final String category;
  final String? merchantName;
  final DateTime date;
  final bool isRecurring;
  final String? notes;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    this.merchantName,
    required this.date,
    this.isRecurring = false,
    this.notes,
  });

  // Fábrica para convertir el documento de Firebase a nuestro Modelo
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['is_expense'] == true ? 'expense' : 'income', // Adaptado a lo que ya programamos
      category: data['category'] ?? 'General',
      merchantName: data['title'] ?? '', // Nuestro 'title' actual es el merchantName
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRecurring: data['is_recurring'] ?? false,
      notes: data['notes'] ?? '',
    );
  }

  // Método para enviar nuestro Modelo a Firebase
  Map<String, dynamic> toFirestore() {
    return {
      'amount': amount,
      'is_expense': type == 'expense',
      'category': category,
      'title': merchantName,
      'date': Timestamp.fromDate(date),
      'is_recurring': isRecurring,
      'notes': notes,
    };
  }
}