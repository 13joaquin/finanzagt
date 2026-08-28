// Archivo: lib/data/models/goal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final String colorHex;

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.colorHex,
  });

  // --- EL NUEVO MÉTODO DE PROGRESO ---
  // Retorna un valor entre 0.0 y 1.0 (ej. 0.75 para 75%)
  double get progress {
    if (targetAmount <= 0) return 0.0;
    // Usamos .clamp para asegurar que el valor nunca pase de 1.0 (100%)
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // FÁBRICA DE ENTRADA: Mapeo sincronizado con el Repositorio
  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return GoalModel(
      id: doc.id,
      name: data['name'] ?? 'Meta sin nombre', // Corregido: 'name'
      targetAmount: (data['targetAmount'] ?? 0).toDouble(), // Corregido: 'targetAmount'
      currentAmount: (data['currentAmount'] ?? 0).toDouble(), // Corregido: 'currentAmount'
      colorHex: data['colorHex'] ?? '#4CAF50',
    );
  }

  // FÁBRICA DE SALIDA: Mapeo sincronizado con el Repositorio
  Map<String, dynamic> toFirestore() {
    return {
      'name': name, // Corregido
      'targetAmount': targetAmount, // Corregido
      'currentAmount': currentAmount, // Corregido
      'colorHex': colorHex,
    };
  }
}