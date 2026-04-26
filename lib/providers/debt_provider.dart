// Archivo: lib/providers/debt_provider.dart
import 'dart:async'; // Necesario para el blindaje de memoria
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/debt_model.dart';

class DebtProvider extends ChangeNotifier {
  List<DebtModel> _debts = [];
  List<DebtModel> get debts => _debts;

  String? _userId;
  StreamSubscription? _debtSubscription; // El blindaje

  // --- ¡AQUÍ ESTÁN LOS GETTERS QUE FALTABAN PARA EL BUDGET_SCREEN! ---

  // 1. Suma del total original de todas las deudas
  double get totalDebtAmount =>
      _debts.fold(0, (sum, item) => sum + item.totalAmount);

  // 2. Suma de lo que aún se debe (saldo pendiente)
  double get totalRemainingAmount =>
      _debts.fold(0, (sum, item) => sum + item.remainingAmount);

  // 3. Suma de lo que ya se ha pagado (Total original - Pendiente)
  double get totalPaidAmount => totalDebtAmount - totalRemainingAmount;


  // --- 1. LEER: Escuchar Firebase en tiempo real (NUEVO MOTOR BLINDADO) ---
  void updateUser(String? uid) {
    if (_userId == uid) return;

    _userId = uid;
    _debtSubscription?.cancel(); // Apagamos escuchas viejas

    if (uid != null) {
      _debtSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('debts')
          .snapshots()
          .listen((snapshot) {

        _debts = snapshot.docs.map((doc) {
          final data = doc.data();
          return DebtModel(
            id: doc.id,
            name: data['name'] ?? 'Deuda sin nombre',
            totalAmount: (data['totalAmount'] ?? 0).toDouble(),
            remainingAmount: (data['remainingAmount'] ?? 0).toDouble(),
            dueDate: (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
            isPaidThisMonth: data['isPaidThisMonth'] ?? false,
          );
        }).toList();

        notifyListeners(); // Avisamos a BudgetScreen que llegaron los datos
      });
    } else {
      _debts = [];
      notifyListeners();
    }
  }

  // --- 2. AGREGAR: Crear una nueva deuda ---
  Future<void> addDebt({
    required String name,
    required double totalAmount,
  }) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users').doc(_userId)
        .collection('debts').add({
      'name': name,
      // Nombres unificados para que coincidan al leer y guardar
      'totalAmount': totalAmount,
      'remainingAmount': totalAmount,
      'dueDate': Timestamp.now(),
      'isPaidThisMonth': false,
    });
  }

  // --- 3. PAGAR: Abonar a una deuda ---
  Future<void> payDebt(String debtId, double paymentAmount) async {
    if (_userId == null) return;

    final debtIndex = _debts.indexWhere((d) => d.id == debtId);
    if (debtIndex == -1) return;

    final currentDebt = _debts[debtIndex];
    double newRemaining = currentDebt.remainingAmount - paymentAmount;

    if (newRemaining < 0) newRemaining = 0;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('debts')
        .doc(debtId)
        .update({
      'remainingAmount': newRemaining,
      'isPaidThisMonth': true,
      'lastPaymentDate': FieldValue.serverTimestamp(),
    });
  }

  // Apagar la conexión al cerrar la app
  @override
  void dispose() {
    _debtSubscription?.cancel();
    super.dispose();
  }
}