import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Función para agregar una transacción y actualizar saldos AL MISMO TIEMPO
  Future<void> addTransaction(String userId, TransactionModel transaction) async {
    final userRef = _firestore.collection('users').doc(userId);
    // Creamos una referencia vacía para obtener un ID autogenerado
    final newTransactionRef = userRef.collection('transactions').doc();

    // Usamos runTransaction para asegurar que si falla la subida de la transacción,
    // tampoco se descuente el dinero por error (Operación Atómica)
    await _firestore.runTransaction((tx) async {

      // 1. Leer los saldos actuales del usuario
      DocumentSnapshot userDoc = await tx.get(userRef);
      double currentSafeToSpend = (userDoc.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;
      double currentNetWorth = (userDoc.data() as Map<String, dynamic>?)?['net_worth']?.toDouble() ?? 0.0;

      // 2. Calcular los nuevos saldos según nuestra regla financiera
      double newSafeToSpend = currentSafeToSpend;
      double newNetWorth = currentNetWorth;

      if (transaction.type == 'expense') {
        newSafeToSpend -= transaction.amount;
        newNetWorth -= transaction.amount;
      } else {
        newSafeToSpend += transaction.amount;
        newNetWorth += transaction.amount;
      }

      // 3. Guardar la transacción usando nuestro Modelo
      tx.set(newTransactionRef, transaction.toFirestore());

      // 4. Actualizar la billetera del usuario
      tx.update(userRef, {
        'safe_balance': newSafeToSpend,
        'net_worth': newNetWorth,
      });
    });
  }
}