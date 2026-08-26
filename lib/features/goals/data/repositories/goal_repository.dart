import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../goals/data/models/goal_model.dart';

class GoalRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. CREAR UNA META NUEVA
  Future<void> createGoal(String uid, GoalModel goal) async {
    await _firestore.collection('users').doc(uid).collection('presentation').add({
      'name': goal.name,
      'targetAmount': goal.targetAmount,
      'currentAmount': goal.currentAmount, // Inicia en 0
      'colorHex': goal.colorHex,
    });
  }

  // 2. ACTUALIZAR NOMBRE O MONTO DE LA META
  Future<void> updateGoal(String uid, String docId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).collection('presentation').doc(docId).update(data);
  }

  // 3. ELIMINAR META (Y devolver el dinero ahorrado al "Seguro para Gastar")
  Future<void> deleteGoal(String uid, String docId) async {
    final userRef = _firestore.collection('users').doc(uid);
    final goalRef = userRef.collection('presentation').doc(docId);

    // Usamos runTransaction para asegurar que no se pierda el dinero
    await _firestore.runTransaction((tx) async {
      final goalSnap = await tx.get(goalRef);
      if (!goalSnap.exists) return;

      double savedAmount = (goalSnap.data() as Map<String, dynamic>)['currentAmount']?.toDouble() ?? 0.0;

      final userSnap = await tx.get(userRef);
      double currentSafe = (userSnap.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;

      // Devolvemos el dinero al saldo seguro y borramos la meta
      tx.update(userRef, {'safe_balance': currentSafe + savedAmount});
      tx.delete(goalRef);
    });
  }

  // 4. ABONAR DINERO A LA META
  Future<void> addFundsToGoal(String uid, String docId, double amount) async {
    final userRef = _firestore.collection('users').doc(uid);
    final goalRef = userRef.collection('presentation').doc(docId);

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final goalSnap = await tx.get(goalRef);

      if (!userSnap.exists || !goalSnap.exists) return;

      double currentSafe = (userSnap.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;
      double currentGoalAmt = (goalSnap.data() as Map<String, dynamic>)['currentAmount']?.toDouble() ?? 0.0;

      // Regla Financiera: El dinero sale del "Seguro para Gastar" y entra a la "Meta"
      tx.update(userRef, {'safe_balance': currentSafe - amount});
      tx.update(goalRef, {'currentAmount': currentGoalAmt + amount});
    });
  }

  // 5. GASTAR DINERO DE LA META
  Future<void> spendFundsFromGoal(String uid, String docId, double amount) async {
    final userRef = _firestore.collection('users').doc(uid);
    final goalRef = userRef.collection('presentation').doc(docId);

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final goalSnap = await tx.get(goalRef);

      if (!userSnap.exists || !goalSnap.exists) return;

      double currentNet = (userSnap.data() as Map<String, dynamic>?)?['net_worth']?.toDouble() ?? 0.0;
      double currentGoalAmt = (goalSnap.data() as Map<String, dynamic>)['currentAmount']?.toDouble() ?? 0.0;

      // Regla Financiera: Gasto real, el dinero sale de la "Meta" y disminuye tu Patrimonio Neto general
      tx.update(userRef, {'net_worth': currentNet - amount});
      tx.update(goalRef, {'currentAmount': currentGoalAmt - amount});
    });
  }
}