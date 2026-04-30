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
      'targetAmount': targetAmount, // Estandarizado
      'currentAmount': 0.0,         // <-- CAMBIO IMPORTANTE: Estandarizado para coincidir con el Repositorio
      'colorHex': colorHex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- 3. ACTUALIZAR: Añadir dinero a una cubeta ---
  Future<void> addSavings(String goalId, double amount) async {
    if (_userId == null) return;

    // CAMBIO CLAVE: Usamos FieldValue.increment al igual que en el TransactionRepository.
    // Esto es 100% seguro contra fallos de sincronización.
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('goals')
        .doc(goalId)
        .update({
      'currentAmount': FieldValue.increment(amount), // Actualización directa en la nube
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