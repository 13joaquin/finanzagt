import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;

  // 'income' (Ingreso), 'expense' (Gasto), 'saving' (Ahorro/Santuario)
  final String type;

  final String category;

  // Campos opcionales para vincular con otros hijos
  final String? goalId; // Si es un ahorro para el Santuario
  final String? debtId; // Si es un pago a una deuda

  TransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
    this.goalId,
    this.debtId,
  });

  // Convertir de Map (Firebase) a Objeto (Dart)
  factory TransactionModel.fromMap(Map<String, dynamic> map, String documentId) {
    return TransactionModel(
      id: documentId,
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: (map['date'] as Timestamp).toDate(),
      type: map['type'] ?? 'expense',
      category: map['category'] ?? 'General',
      goalId: map['goalId'],
      debtId: map['debtId'],
    );
  }

  // Convertir de Objeto (Dart) a Map (Firebase)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date),
      'type': type,
      'category': category,
      'goalId': goalId,
      'debtId': debtId,
    };
  }
}