import 'package:cloud_firestore/cloud_firestore.dart';

class DebtModel {
  final String id;
  final String name;
  final double totalAmount;
  final double remainingAmount;
  final DateTime dueDate;
  final bool isPaidThisMonth;

  DebtModel({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.remainingAmount,
    required this.dueDate,
    this.isPaidThisMonth = false,
  });

  // Cálculo para el motor visual del Santuario[cite: 2, 4]
  double get paymentProgress {
    if (totalAmount <= 0) return 0.0;
    return (totalAmount - remainingAmount) / totalAmount;
  }

  // Soporte para Firestore y Provider[cite: 1, 6]
  factory DebtModel.fromMap(String id, Map<String, dynamic> data) {
    return DebtModel(
      id: id,
      name: data['name'] ?? 'Deuda sin nombre',
      totalAmount: (data['totalAmount'] ?? 0).toDouble(),
      remainingAmount: (data['remainingAmount'] ?? 0).toDouble(),
      dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPaidThisMonth: data['isPaidThisMonth'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalAmount': totalAmount,
      'remainingAmount': remainingAmount,
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaidThisMonth': isPaidThisMonth,
    };
  }
}
