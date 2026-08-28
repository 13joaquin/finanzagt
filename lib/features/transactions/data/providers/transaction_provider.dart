import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/transaction_model.dart';

final transactionProvider = NotifierProvider<TransactionProvider,
    List<TransactionModel>>(
  TransactionProvider.new,
);

class TransactionProvider extends Notifier<List<TransactionModel>> {
  String? _userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
  _transactionsSubscription;

  List<TransactionModel> get transactions => state;

  double get totalIncomes => state
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalExpenses => state
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get totalSavings => state
      .where((t) => t.type == 'saving')
      .fold(0.0, (sum, item) => sum + item.amount);

  double get netWorth => totalIncomes - totalExpenses;

  @override
  List<TransactionModel> build() {
    ref.onDispose(() {
      _transactionsSubscription?.cancel();
    });

    return [];
  }

  void listenToTransactions(String uid) {
    _userId = uid;
    _transactionsSubscription?.cancel();
    _transactionsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs
          .map((doc) => TransactionModel.fromFirestore(doc))
          .toList();
    }, onError: (error) {
      print('Error en el stream de transacciones: $error');
    });
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('transactions')
        .add(transaction.toFirestore());
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
