// Archivo: lib/data/models/goal_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class GoalModel {
  final String id;
  final String name; // En MVP: title
  final double targetAmount;
  final double currentAmount; // En MVP: saved_amount
  final String colorHex; // Adaptación del color_code

  GoalModel({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.colorHex,
  });

  factory GoalModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return GoalModel(
      id: doc.id,
      name: data['title'] ?? 'Meta sin nombre',
      targetAmount: (data['target_amount'] ?? 0).toDouble(),
      currentAmount: (data['saved_amount'] ?? 0).toDouble(),
      colorHex: data['colorHex'] ?? '#4CAF50', // Color verde por defecto
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': name,
      'target_amount': targetAmount,
      'saved_amount': currentAmount,
      'colorHex': colorHex,
    };
  }
}