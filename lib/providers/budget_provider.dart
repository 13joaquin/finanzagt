// Archivo: lib/providers/budget_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetProvider extends ChangeNotifier {
  String? _userId;

  // Variables principales del presupuesto
  double _monthlyIncome = 0.0;
  double _limitNeeds = 0.0;
  double _limitWants = 0.0;
  double _limitSavings = 0.0;

  // Getters para que la UI pueda leer los datos
  double get monthlyIncome => _monthlyIncome;
  double get limitNeeds => _limitNeeds;
  double get limitWants => _limitWants;
  double get limitSavings => _limitSavings;

  // --- LEER: Escuchar la configuración del usuario en Firebase ---
  void listenToBudget(String uid) {
    _userId = uid;

    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((snapshot) {

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;

        _monthlyIncome = (data['monthly_income'] ?? 0).toDouble();
        _limitNeeds = (data['limit_needs'] ?? 0).toDouble();
        _limitWants = (data['limit_wants'] ?? 0).toDouble();
        _limitSavings = (data['limit_savings'] ?? 0).toDouble();

        // Avisamos a la pantalla de Presupuesto que los límites han cambiado
        notifyListeners();
      }
    });
  }

  // --- ACTUALIZAR: Guardar nueva configuración de ingresos ---
  Future<void> updateIncomeAndLimits(double newIncome) async {
    if (_userId == null) return;

    // Calculamos la regla 50/30/20 automáticamente
    double needs = newIncome * 0.50;
    double wants = newIncome * 0.30;
    double savings = newIncome * 0.20;

    await FirebaseFirestore.instance.collection('users').doc(_userId).update({
      'monthly_income': newIncome,
      'limit_needs': needs,
      'limit_wants': wants,
      'limit_savings': savings,
    });
  }
}