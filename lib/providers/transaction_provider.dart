import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  String? _userId;

  // Getters para obtener las listas
  List<TransactionModel> get transactions => _transactions;

  // --- 1. LÓGICA DE CÁLCULO (Adiós a los saltos de patrimonio) ---

  // Suma total de todos los ingresos registrados
  double get totalIncomes => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  // Suma total de todos los gastos registrados
  double get totalExpenses => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  // Suma total de lo enviado al Santuario (Ahorros)
  double get totalSavings => _transactions
      .where((t) => t.type == 'saving')
      .fold(0.0, (sum, item) => sum + item.amount);

  // PATRIMONIO NETO REAL: Ingresos - Gastos
  // Nota: Los ahorros (saving) no restan al patrimonio total,
  // solo se mueven de "disponible" a "ahorrado".
  double get netWorth => totalIncomes - totalExpenses;

  // --- 2. COMUNICACIÓN CON FIREBASE ---

  void listenToTransactions(String uid) {
    _userId = uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true) // Ordenar por fecha
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromMap(doc.data(), doc.id))
          .toList();

      notifyListeners(); // Avisar a la app que el dinero cambió
    });
  }

  // --- 3. ACCIONES: Agregar y Eliminar ---

  Future<void> addTransaction(TransactionModel transaction) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .add(transaction.toMap());
  }

  Future<void> deleteTransaction(String transactionId) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }
}