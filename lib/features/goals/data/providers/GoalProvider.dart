// lib/providers/goal_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalProvider extends ChangeNotifier {
  List<GoalModel> _goals = [];
  List<GoalModel> get goals => _goals;
  String? _userId;

  void listenToGoals(String uid) {
    _userId = uid;
    FirebaseFirestore.instance
        .collection('users').doc(uid)
        .collection('presentation')
        .snapshots()
        .listen((snapshot) {
      _goals = snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();
      notifyListeners();
    });
  }

  // CÁLCULO MAESTRO: Suma todo lo que hay en las cubetas del Santuario
  double get totalSaved => _goals.fold(0.0, (sum, item) => sum + item.currentAmount);

  // Meta total combinada (cuánto queremos ahorrar en total)
  double get totalTarget => _goals.fold(0.0, (sum, item) => sum + item.targetAmount);

  Future<void> addGoal({required String name, required double targetAmount, required String colorHex}) async {
    if (_userId == null) return;
    await FirebaseFirestore.instance.collection('users').doc(_userId).collection('presentation').add({
      'title': name,
      'targetAmount': targetAmount,
      'currentAmount': 0.0,
      'colorHex': colorHex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}