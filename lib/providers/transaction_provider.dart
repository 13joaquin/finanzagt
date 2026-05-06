// Archivo: lib/providers/transaction_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  List<TransactionModel> _transactions = [];
  String? _userId;

  List<TransactionModel> get transactions => _transactions;

  double get totalIncomes => _transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => _transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalSavings => _transactions
      .where((t) => t.type == 'saving')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get netWorth => totalIncomes - totalExpenses;

  // --- COMUNICACIÓN CON FIREBASE ---
  void listenToTransactions(String uid) {
    _userId = uid;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc)) // <-- CORREGIDO
          .toList();

      notifyListeners();
    }, onError: (error) {
      // Agregamos un print para evitar que fallos futuros pasen en silencio
      print("Error en el stream de transacciones: $error");
    });
  }

  // --- ACCIONES ---
  Future<void> addTransaction(TransactionModel transaction) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .add(transaction.toFirestore()); // <-- CORREGIDO
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