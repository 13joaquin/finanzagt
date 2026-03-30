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

  // --- NUEVA FUNCIÓN PARA ELIMINAR (AHORA SÍ ESTÁ DENTRO DE LA CLASE) ---
  Future<void> deleteTransaction({
    required String userId,
    required String docId,
    required double amount,
    required bool isExpense,
  }) async {
    final userRef = _firestore.collection('users').doc(userId);
    final transactionRef = userRef.collection('transactions').doc(docId);

    // Usamos una transacción atómica para que el borrado y la actualización de saldo
    // ocurran al mismo tiempo o no ocurra nada (evita descuadres).
    await _firestore.runTransaction((tx) async {
      DocumentSnapshot userDoc = await tx.get(userRef);
      if (!userDoc.exists) return;

      double currentSafe = (userDoc.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;
      double currentNet = (userDoc.data() as Map<String, dynamic>?)?['net_worth']?.toDouble() ?? 0.0;

      // Lógica inversa: Si borramos un gasto, devolvemos el dinero al saldo.
      // Si borramos un ingreso, restamos ese dinero del saldo.
      double newSafe = isExpense ? (currentSafe + amount) : (currentSafe - amount);
      double newNet = isExpense ? (currentNet + amount) : (currentNet - amount);

      tx.delete(transactionRef);
      tx.update(userRef, {
        'safe_balance': newSafe,
        'net_worth': newNet,
      });
    });
  }
} // <-- ESTA ES LA ÚLTIMA LLAVE QUE CIERRA LA CLASE