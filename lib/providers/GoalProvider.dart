// Archivo: lib/providers/goal_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  List<GoalModel> _goals = [];
  List<GoalModel> get goals => _goals;
  String? _userId;

  // --- 1. LEER: Escuchar las metas en tiempo real ---
  void listenToGoals(String uid) {
    _userId = uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .listen((snapshot) {

      _goals = snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();

      // Notifica a las pantallas y al Santuario que el ahorro cambió
      notifyListeners();
    });
  }

  // --- 2. AGREGAR: Crear una nueva meta (cubeta) ---
  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required String colorHex,
  }) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('goals')
        .add({
      'title': name,
      'target_amount': targetAmount,
      'saved_amount': 0.0, // Empieza en cero
      'colorHex': colorHex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- 3. ACTUALIZAR: Añadir dinero a una cubeta ---
  Future<void> addSavings(String goalId, double amount) async {
    if (_userId == null) return;

    // Buscamos la meta localmente para obtener el saldo actual
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final currentAmount = _goals[goalIndex].currentAmount;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('goals')
        .doc(goalId)
        .update({
      'saved_amount': currentAmount + amount,
    });
  }

  // --- CÁLCULOS GLOBALES ---
  // Suma total de lo ahorrado en todas las metas
  double get totalSaved => _goals.fold(0, (sum, item) => sum + item.currentAmount);

  // Promedio de progreso total (Útil para el Santuario)
  double get globalProgress {
    if (_goals.isEmpty) return 0.0;
    double totalProgress = _goals.fold(0, (sum, item) => sum + item.progress);
    return totalProgress / _goals.length;
  }
}