// Archivo: lib/data/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String type;
  final String category;

  TransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  // Convierte el objeto de Dart a un formato que Firebase entiende.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date), // Siempre guardamos como Timestamp
      'type': type,
      'category': category,
    };
  }

  // Toma los datos de Firebase y crea un objeto con LÓGICA DE FECHAS BLINDADA.
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    // Evaluamos inteligentemente el tipo de dato de la fecha
    DateTime parsedDate;
    if (data['date'] is Timestamp) {
      parsedDate = (data['date'] as Timestamp).toDate();
    } else if (data['date'] is String) {
      // Por si quedaron registros antiguos guardados como texto
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
    );
  }
}