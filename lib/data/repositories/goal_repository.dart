import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/goal_model.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. Crear una nueva meta desde cero
  Future<void> createGoal(String userId, GoalModel goal) async {
    final userRef = _firestore.collection('users').doc(userId);
    await userRef.collection('goals').add(goal.toFirestore());
  }

  // 2. ABONAR a la meta (Baja Seguro para Gastar, Patrimonio Neto Intacto)
  Future<void> addFundsToGoal(String userId, String goalId, double amountToAdd) async {
    final userRef = _firestore.collection('users').doc(userId);
    final goalRef = userRef.collection('goals').doc(goalId);

    await _firestore.runTransaction((tx) async {
      DocumentSnapshot userDoc = await tx.get(userRef);
      DocumentSnapshot goalDoc = await tx.get(goalRef);

      double currentSafeToSpend = (userDoc.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;
      double currentSaved = (goalDoc.data() as Map<String, dynamic>?)?['saved_amount']?.toDouble() ?? 0.0;

      // Actualizamos Seguro para Gastar y el saldo de la Meta
      tx.update(userRef, {'safe_balance': currentSafeToSpend - amountToAdd});
      tx.update(goalRef, {'saved_amount': currentSaved + amountToAdd});

      // Opcional: Registrar el movimiento como transacción para el historial
      tx.set(userRef.collection('transactions').doc(), {
        'title': 'Abono a Meta',
        'category': 'Ahorro',
        'amount': amountToAdd,
        'is_expense': true, // Es salida del flujo de caja diario
        'date': FieldValue.serverTimestamp(),
      });
    });
  }

  // 3. GASTAR de la meta (Baja la Meta, Baja el Patrimonio Neto)
  Future<void> spendFromGoal(String userId, String goalId, double amountToSpend, String reason) async {
    final userRef = _firestore.collection('users').doc(userId);
    final goalRef = userRef.collection('goals').doc(goalId);

    await _firestore.runTransaction((tx) async {
      DocumentSnapshot userDoc = await tx.get(userRef);
      DocumentSnapshot goalDoc = await tx.get(goalRef);

      double currentNetWorth = (userDoc.data() as Map<String, dynamic>?)?['net_worth']?.toDouble() ?? 0.0;
      double currentSaved = (goalDoc.data() as Map<String, dynamic>?)?['saved_amount']?.toDouble() ?? 0.0;

      // Actualizamos Patrimonio Neto y el saldo de la Meta
      tx.update(userRef, {'net_worth': currentNetWorth - amountToSpend});
      tx.update(goalRef, {'saved_amount': currentSaved - amountToSpend});

      // Registramos en qué se gastó ese ahorro
      tx.set(userRef.collection('transactions').doc(), {
        'title': 'Gasto de Ahorro: $reason',
        'category': 'Uso de Meta',
        'amount': amountToSpend,
        'is_expense': true,
        'date': FieldValue.serverTimestamp(),
      });
    });
  }
}