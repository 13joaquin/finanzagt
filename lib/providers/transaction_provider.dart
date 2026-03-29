import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionProvider extends ChangeNotifier {
  List<QueryDocumentSnapshot> _transactions = [];
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<String> _categories = ['Todas'];
  bool _isLoading = true;

  // Variables públicas para que la pantalla las lea fácilmente
  List<QueryDocumentSnapshot> get transactions => _transactions;
  double get totalIncome => _totalIncome;
  double get totalExpense => _totalExpense;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  void listenToTransactions(String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .listen((snapshot) {

      _transactions = snapshot.docs;

      // Reiniciamos los contadores cada vez que hay un cambio
      _totalIncome = 0.0;
      _totalExpense = 0.0;
      _categories = ['Todas'];

      // Hacemos las matemáticas aquí, ¡lejos de la pantalla visual!
      for (var doc in _transactions) {
        var data = doc.data() as Map<String, dynamic>;
        double amt = (data['amount'] ?? 0).toDouble();

        // Asumimos que si no existe 'is_expense', por seguridad es un gasto.
        // OJO: Si en tu modelo usaste 'type' == 'expense', cambia esto a:
        // bool isExp = data['type'] == 'expense';
        bool isExp = data['is_expense'] ?? true;

        if (isExp) {
          _totalExpense += amt;
        } else {
          _totalIncome += amt;
        }

        String cat = data['category'] ?? '';
        if (cat.isNotEmpty && !_categories.contains(cat)) {
          _categories.add(cat);
        }
      }

      _isLoading = false;
      notifyListeners(); // Le avisamos al Dashboard que ya tenemos los datos listos
    });
  }
}