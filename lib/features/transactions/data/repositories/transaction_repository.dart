// Archivo: lib/data/repositories/transaction_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Obtener Transacciones en tiempo real
  Stream<List<TransactionModel>> getUserTransactions(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList());
  }

  // 2. EL GRAN CABLEADO (Movimiento de Dinero - PASO 3)
  // Agregamos un parámetro opcional "goalId" para saber a qué maceta va el dinero
  Future<void> addTransaction(String uid, TransactionModel transaction, {String? goalId}) async {

    // Usamos un "Batch" (Lote) para hacer múltiples operaciones al mismo tiempo
    final batch = _db.batch();

    // A. Preparamos la nueva transacción
    final docRef = _db.collection('users').doc(uid).collection('transactions').doc();
    batch.set(docRef, transaction.toFirestore());

    // B. La Magia del Ahorro Real
    // Si es un ahorro y sabemos a qué meta va dirigida, movemos el dinero.
    if (transaction.type == 'saving' && goalId != null && goalId.isNotEmpty) {
      final goalRef = _db.collection('users').doc(uid).collection('goals').doc(goalId);

      // FieldValue.increment le dice a Firebase:
      // "Súmale este nuevo monto a lo que ya estaba ahorrado en la maceta"
      batch.update(goalRef, {
        'currentAmount': FieldValue.increment(transaction.amount)
      });
    }

    // C. Ejecutamos la operación combinada (Transacción + Actualización de Meta)
    await batch.commit();
  }

  // 3. Eliminar Transacción
  Future<void> deleteTransaction(String uid, String transactionId) async {
    await _db.collection('users').doc(uid).collection('transactions').doc(transactionId).delete();
  }
}