// Archivo: lib/providers/expenseProvider.dart
import 'dart:async'; // Necesario para apagar el Stream
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  String? _userId;
  StreamSubscription? _expenseSubscription;

  // --- ¡AQUÍ ESTÁN LOS GETTERS CORREGIDOS PARA EL DASHBOARD! ---

  // 1. Agregamos el puente público para la lista completa de gastos
  List<ExpenseModel> get expenses => _expenses;

  // Obtener solo gastos fijos
  List<ExpenseModel> get fixedExpenses =>
      _expenses.where((e) => e.isFixed).toList();

  // Obtener solo gastos flexibles
  List<ExpenseModel> get flexibleExpenses =>
      _expenses.where((e) => !e.isFixed).toList();

  // --- CÁLCULOS PARA EL DASHBOARD Y EL SANTUARIO ---

  // 2. Renombramos 'totalFixedAmount' a 'totalFixedExpenses'
  double get totalFixedExpenses =>
      fixedExpenses.fold(0, (sum, item) => sum + item.amount);

  // 3. Renombramos 'totalFlexibleAmount' a 'totalFlexibleExpenses'
  double get totalFlexibleExpenses =>
      flexibleExpenses.fold(0, (sum, item) => sum + item.amount);

  // Total general actualizado con los nuevos nombres
  double get totalAllExpenses => totalFixedExpenses + totalFlexibleExpenses;


  // --- 1. LEER: Escuchar gastos en tiempo real (NUEVO MOTOR) ---
  void updateUser(String? uid) {
    // Si es el mismo usuario, no hacemos nada
    if (_userId == uid) return;

    _userId = uid;
    // Cancelamos cualquier "escucha" anterior por seguridad
    _expenseSubscription?.cancel();

    if (uid != null) {
      // Encendemos el radar hacia Firebase
      _expenseSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('expenses')
          .orderBy('date', descending: true)
          .snapshots()
          .listen((snapshot) {

        _expenses = snapshot.docs.map((doc) => ExpenseModel.fromFirestore(doc)).toList();
        notifyListeners(); // ¡Avisa al Dashboard que llegaron los datos!

      });
    } else {
      // Si el usuario cierra sesión, limpiamos la lista
      _expenses = [];
      notifyListeners();
    }
  }

  // --- 2. AGREGAR: Nuevo gasto ---
  Future<void> addExpense({
    required String name,
    required double amount,
    required bool isFixed,
    required String category,
  }) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('expenses')
        .add({
      'name': name,
      'amount': amount,
      'is_fixed': isFixed,
      'category': category,
      'date': Timestamp.now(),
    });
  }

  // Cuando la app se cierra, apagamos el radar
  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}