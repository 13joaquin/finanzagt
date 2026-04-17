// Archivo: lib/providers/debt_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/debt_model.dart'; // <-- Ajusta la ruta si es necesario

class DebtProvider extends ChangeNotifier {
  // Aquí guardamos la lista de deudas en la memoria de la app
  List<DebtModel> _debts = [];
  List<DebtModel> get debts => _debts;

  String? _userId;

  // --- 1. LEER: Escuchar Firebase en tiempo real ---
  void listenToDebts(String uid) {
    _userId = uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('debts') // Subcolección exclusiva para deudas
        .snapshots()
        .listen((snapshot) {

      // Transformamos los documentos de Firebase en nuestros "Moldes" (DebtModel)
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

      // Le avisamos a las pantallas que la lista de deudas cambió
      notifyListeners();
    });
  }

  // --- 2. AGREGAR: Crear una nueva deuda ---
  Future<void> addDebt({
    required String name,
    required double totalAmount,
    required DateTime dueDate,
  }) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('debts')
        .add({
      'name': name,
      'totalAmount': totalAmount,
      'remainingAmount': totalAmount, // Al inicio, debes todo el monto
      'dueDate': Timestamp.fromDate(dueDate),
      'isPaidThisMonth': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // --- 3. PAGAR: Abonar a una deuda ---
  Future<void> payDebt(String debtId, double paymentAmount) async {
    if (_userId == null) return;

    // Buscamos la deuda en nuestra lista actual para saber cuánto debe
    final debtIndex = _debts.indexWhere((d) => d.id == debtId);
    if (debtIndex == -1) return;

    final currentDebt = _debts[debtIndex];
    double newRemaining = currentDebt.remainingAmount - paymentAmount;

    // Nos aseguramos de que la deuda no quede en números negativos si pagó de más
    if (newRemaining < 0) newRemaining = 0;

    // Actualizamos el dato en Firebase
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('debts')
        .doc(debtId)
        .update({
      'remainingAmount': newRemaining,
      'isPaidThisMonth': true, // Celebramos que ya hizo un pago este mes
      'lastPaymentDate': FieldValue.serverTimestamp(),
    });
  }
}