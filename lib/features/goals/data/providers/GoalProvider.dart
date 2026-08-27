// Archivo: lib/providers/goal_provider.dart

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/goal_model.dart';

final goalProvider = NotifierProvider<GoalProvider, List<GoalModel>>(
  GoalProvider.new,
);

class GoalProvider extends Notifier<List<GoalModel>> {
  String? _userId;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _goalsSubscription;

  List<GoalModel> get goals => state;

  @override
  List<GoalModel> build() {
    ref.onDispose(() {
      _goalsSubscription?.cancel();
    });

    return [];
  }

  void listenToGoals(String uid) {
    _userId = uid;
    _goalsSubscription?.cancel();

    _goalsSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('goals')
        .snapshots()
        .listen((snapshot) {
      state = snapshot.docs.map((doc) => GoalModel.fromFirestore(doc)).toList();
    });
  }

  double get totalSaved =>
      state.fold(0.0, (sum, item) => sum + item.currentAmount);

  double get totalTarget =>
      state.fold(0.0, (sum, item) => sum + item.targetAmount);

  Future<void> addGoal({
    required String name,
    required double targetAmount,
    required String colorHex,
  }) async {
    if (_userId == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('goals')
        .add({
      'title': name,
      'targetAmount': targetAmount,
      'currentAmount': 0.0,
      'colorHex': colorHex,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}