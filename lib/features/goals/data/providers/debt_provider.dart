import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/debt_model.dart';

final debtProvider = NotifierProvider<DebtProvider, List<DebtModel>>(
  DebtProvider.new,
);

class DebtProvider extends Notifier<List<DebtModel>> {
  List<DebtModel> get debts => state;

  String? _userId;
  StreamSubscription? _debtSubscription;

  // --- Getters para Dashboard y BudgetScreen[cite: 1, 4] ---
  double get totalDebtAmount => state.fold(0, (sum, item) => sum + item.totalAmount);
  double get totalRemainingAmount => state.fold(0.0, (sum, item) => sum + item.remainingAmount);
  double get totalPaidAmount => totalDebtAmount - totalRemainingAmount;
  double get totalInitialDebt => state.fold(0.0, (sum, item) => sum + item.totalAmount);

  @override
  List<DebtModel> build() {
    ref.onDispose(() {
      _debtSubscription?.cancel();
    });

    return [];
  }

  // --- Motor de Sincronización Blindado ---
  void updateUser(String? uid) {
    if (_userId == uid) return;
    _userId = uid;
    _debtSubscription?.cancel();

    if (uid != null) {
      _debtSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('debts')
          .snapshots()
          .listen((snapshot) {
        state = snapshot.docs.map((doc) => DebtModel.fromMap(doc.id, doc.data())).toList();
      });
    } else {
      state = [];
    }
  }

  // --- Crear Deuda ---
  Future<void> addDebt({required String name, required double totalAmount}) async {
    if (_userId == null) return;
    await FirebaseFirestore.instance
        .collection('users').doc(_userId)
        .collection('debts').add({
      'name': name,
      'totalAmount': totalAmount,
      'remainingAmount': totalAmount,
      'dueDate': Timestamp.now(),
      'isPaidThisMonth': false,
    });
  }

  // --- Sistema de Pago Atómico (Deuda + Transacción)[cite: 1, 6] ---
  Future<void> payDebt(String debtId, double paymentAmount, String debtName) async {
    if (_userId == null) return;

    final batch = FirebaseFirestore.instance.batch();

    // Referencia a la deuda
    final debtRef = FirebaseFirestore.instance
        .collection('users').doc(_userId)
        .collection('debts').doc(debtId);

    // Referencia a la nueva transacción de gasto
    final transactionRef = FirebaseFirestore.instance
        .collection('users').doc(_userId)
        .collection('transactions').doc();

    // 1. Actualizamos la deuda restando el abono
    batch.update(debtRef, {
      'remainingAmount': FieldValue.increment(-paymentAmount),
      'isPaidThisMonth': true,
      'lastPaymentDate': FieldValue.serverTimestamp(),
    });

    // 2. Creamos el gasto automáticamente para afectar el Flujo de Caja[cite: 4]
    batch.set(transactionRef, {
      'amount': paymentAmount,
      'type': 'expense',
      'category': 'Deudas', // Vinculado a tu cubeta de ahorro y metas
      'name': 'Abono: $debtName', // <-- CORREGIDO PARA QUE EL MODELO LO LEA
      'date': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}