import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. AGREGAR TRANSACCIÓN (Y actualizar saldos al mismo tiempo)
  Future<void> addTransaction(String userId, TransactionModel transaction) async {
    final userRef = _firestore.collection('users').doc(userId);
    final newTransactionRef = userRef.collection('transactions').doc();

    await _firestore.runTransaction((tx) async {
      DocumentSnapshot userDoc = await tx.get(userRef);
      double currentSafeToSpend = (userDoc.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;
      double currentNetWorth = (userDoc.data() as Map<String, dynamic>?)?['net_worth']?.toDouble() ?? 0.0;

      double newSafeToSpend = currentSafeToSpend;
      double newNetWorth = currentNetWorth;

      if (transaction.type == 'expense') {
        newSafeToSpend -= transaction.amount;
        newNetWorth -= transaction.amount;
      } else {
        newSafeToSpend += transaction.amount;
        newNetWorth += transaction.amount;
      }

      // Guardamos usamos "toFirestore" del modelo
      tx.set(newTransactionRef, transaction.toFirestore());

      tx.update(userRef, {
        'safe_balance': newSafeToSpend,
        'net_worth': newNetWorth,
      });
    });
  }

  // 2. ELIMINAR TRANSACCIÓN (Y devolver el dinero al saldo)
  Future<void> deleteTransaction({
    required String userId,
    required String docId,
    required double amount,
    required bool isExpense,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final transactionRef = userRef.collection('transactions').doc(docId);

    await _firestore.runTransaction((tx) async {
      DocumentSnapshot userDoc = await tx.get(userRef);
      if (!userDoc.exists) return;

      double currentSafe = (userDoc.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;
      double currentNet = (userDoc.data() as Map<String, dynamic>?)?['net_worth']?.toDouble() ?? 0.0;

      double newSafe = isExpense ? (currentSafe + amount) : (currentSafe - amount);
      double newNet = isExpense ? (currentNet + amount) : (currentNet - amount);

      tx.delete(transactionRef);
      tx.update(userRef, {
        'safe_balance': newSafe,
        'net_worth': newNet,
      });
    });
  }

  // 3. OBTENER CATEGORÍAS DEL USUARIO (Nuevo)
  Future<List<String>> getUserCategories(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();

    // Si el usuario tiene categorías guardadas, las usamos. Si no, damos las por defecto.
    if (userDoc.exists) {
      var data = userDoc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('categories')) {
        return List<String>.from(data['categories']);
      }
    }
    return ['Comida', 'Transporte', 'Vivienda', 'Ocio/Flexible', 'Salario', 'Ventas', 'Otros'];
  }

  // 4. ACTUALIZAR TRANSACCIÓN (Nuevo)
  Future<void> updateTransaction(String userId, String docId, TransactionModel transaction) async {
    // Para no complicar la matemática de edición, actualizamos solo el texto de la transacción en esta fase.
    await _firestore.collection('users').doc(userId).collection('transactions').doc(docId).update(transaction.toFirestore());
  }
}