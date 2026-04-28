// Archivo: lib/data/models/transaction_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String name;
  final double amount;
  final DateTime date;
  final String type;     // 'income', 'expense' o 'saving'
  final String category;

  TransactionModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
    required this.type,
    required this.category,
  });

  // EL TRADUCTOR (toFirestore):
  // Este es el método que soluciona los errores en tu TransactionRepository.
  // Convierte el objeto de Dart a un mapa que Firebase puede entender.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date), // Firebase usa Timestamps para fechas
      'type': type,
      'category': category,
      // Nota: El 'id' no se envía en el cuerpo porque es el nombre del documento en Firebase
    };
  }

  // FACTORY (fromFirestore):
  // Esto te servirá para el futuro cuando quieras LEER los datos de la nube
  // y convertirlos de nuevo en objetos de tu app.
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TransactionModel(
      id: doc.id,
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? '',
      category: data['category'] ?? '',
    );
  }
}