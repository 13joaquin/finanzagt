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

// --- 1. PARA FIREBASE (Firestore) ---
  // Convierte el objeto de Dart a un formato que Firebase entiende.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'amount': amount,
      'date': Timestamp.fromDate(date), // Convertimos DateTime a Timestamp de Firebase
      'type': type,
      'category': category,
      // El 'id' no se pone aquí porque es el nombre del documento.
    };
  }

  // 2. LA FÁBRICA DE ENTRADA (fromFirestore):
  // Toma los datos crudos de Firebase y crea un objeto TransactionModel.
  factory TransactionModel.fromFirestore(DocumentSnapshot doc) {
    // Verificamos que existan datos en el documento
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return TransactionModel(
      id: doc.id, // El ID se saca del nombre del documento
      name: data['name'] ?? '',
      amount: (data['amount'] ?? 0.0).toDouble(),
      // Convertimos el Timestamp de Firebase de vuelta a DateTime de Dart
      date: (data['date'] as Timestamp).toDate(),
      type: data['type'] ?? 'expense',
      category: data['category'] ?? 'General',
    );
  }
  // --- 2. PARA EL PROVIDER (Mapas estándar) ---
  // Estos son los que el Provider está pidiendo ahora mismo

  // Dart -> Mapa (Incluye el ID y convierte fecha a String)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(), // Convertimos a texto para mapas simples
      'type': type,
      'category': category,
    };
  }

  // Mapa -> Dart
  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      name: map['name'] ?? '',
      amount: (map['amount'] ?? 0.0).toDouble(),
      date: DateTime.parse(map['date'] ?? DateTime.now().toIso8601String()),
      type: map['type'] ?? 'expense',
      category: map['category'] ?? 'General',
    );
  }
}
