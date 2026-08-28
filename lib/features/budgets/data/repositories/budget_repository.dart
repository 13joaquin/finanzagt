import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore;

  BudgetRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getBudget(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return doc.data();
  }

  Future<void> saveBudget({
    required String uid,
    required double monthlyIncome,
    required double limitNeeds,
    required double limitWants,
    required double limitSavings,
  }) async {
    await _firestore.collection('users').doc(uid).set(
      {
        'monthly_income': monthlyIncome,
        'limit_needs': limitNeeds,
        'limit_wants': limitWants,
        'limit_savings': limitSavings,
        'last_budget_update': Timestamp.now(),
      },
      SetOptions(merge: true),
    );
  }
}