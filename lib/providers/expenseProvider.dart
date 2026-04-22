// Archivo: lib/providers/expenseProvider.dart
import 'dart:async'; // Necesario para apagar el Stream
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  List<ExpenseModel> _expenses = [];
  String? _userId;
  StreamSubscription? _expenseSubscription;

  // Obtener solo gastos fijos
  List<ExpenseModel> get fixedExpenses =>
      _expenses.where((e) => e.isFixed).toList();

  // Obtener solo gastos flexibles
  List<ExpenseModel> get flexibleExpenses =>
      _expenses.where((e) => !e.isFixed).toList();

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

  // --- CÁLCULOS PARA EL SANTUARIO ---
  double get totalFixedAmount =>
      fixedExpenses.fold(0, (sum, item) => sum + item.amount);

  double get totalFlexibleAmount =>
      flexibleExpenses.fold(0, (sum, item) => sum + item.amount);

  double get totalAllExpenses => totalFixedAmount + totalFlexibleAmount;

  // Cuando la app se cierra, apagamos el radar
  @override
  void dispose() {
    _expenseSubscription?.cancel();
    super.dispose();
  }
}