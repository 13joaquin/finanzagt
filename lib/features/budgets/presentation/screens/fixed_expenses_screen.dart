import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/user_provider.dart'; // Importamos el Provider

class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // ==========================================
  // FUNCIONES CONECTADAS AL UID REAL
  // ==========================================
  Future<void> _saveNewExpense(String uid, String title, double amount) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('fixed_expenses').add({
        'title': title,
        'amount': amount,
        'isPaid': false,
        'color': '#4A47F6',
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error guardando gasto fijo: $e");
    }
  }

  Future<void> _updateExpense(String uid, String docId, String title, double amount) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('fixed_expenses').doc(docId).update({
        'title': title,
        'amount': amount,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error actualizando gasto fijo: $e");
    }
  }

  Future<void> _deleteExpense(String uid, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).collection('fixed_expenses').doc(docId).delete();
    } catch (e) {
      debugPrint("Error borrando gasto fijo: $e");
    }
  }

  Future<void> _payFixedExpense(String uid, String title, double amount) async {
    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final newTransactionRef = userRef.collection('transactions').doc();

      await FirebaseFirestore.instance.runTransaction((tx) async {
        final userDoc = await tx.get(userRef);
        double currentSafe = (userDoc.data() as Map<String, dynamic>?)?['safe_balance']?.toDouble() ?? 0.0;
        double currentNet = (userDoc.data() as Map<String, dynamic>?)?['net_worth']?.toDouble() ?? 0.0;

        // Descontamos el dinero de los saldos generales
        tx.update(userRef, {
          'safe_balance': currentSafe - amount,
          'net_worth': currentNet - amount,
        });

        // Lo registramos como una transacción real
        tx.set(newTransactionRef, {
          'title': 'Pago Fijo: $title',
          'amount': amount,
          'type': 'expense',
          'category': 'Gastos Fijos',
          'date': Timestamp.now(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pago de $title registrado. ✓'), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint("Error pagando gasto fijo: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. OBTENER USUARIO REAL
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final String uid = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gastos Fijos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 2. CONECTAR AL STREAM DEL USUARIO REAL
        stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('fixed_expenses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Algo salió mal'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final expenses = snapshot.data!.docs;

          if (expenses.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.home_work_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Aún no tienes gastos fijos", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: expenses.length,
            itemBuilder: (context, index) {
              final doc = expenses[index];
              final data = doc.data() as Map<String, dynamic>;

              return _buildExpenseCard(
                uid: uid,
                docId: doc.id,
                title: data['title'] ?? 'Gasto Fijo',
                amount: (data['amount'] ?? 0).toDouble(),
                color: const Color(0xFF4A47F6),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showExpenseFormModal(uid: uid),
        label: const Text('Nuevo Gasto Fijo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF4A47F6),
      ),
    );
  }

  // MODAL PARA CREAR / EDITAR
  void _showExpenseFormModal({required String uid, String? docId, String? currentTitle, double? currentAmount}) {
    if (docId != null) {
      _titleController.text = currentTitle ?? '';
      _amountController.text = currentAmount?.toStringAsFixed(0) ?? '';
    } else {
      _titleController.clear();
      _amountController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(docId == null ? 'Nuevo Gasto Fijo' : 'Editar Gasto', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Nombre (ej. Alquiler)')),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto (Q)')),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final title = _titleController.text;
                  final amt = double.tryParse(_amountController.text) ?? 0;
                  if (docId == null) {
                    _saveNewExpense(uid, title, amt);
                  } else {
                    _updateExpense(uid, docId, title, amt);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4A47F6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Guardar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // WIDGET TARJETA
  Widget _buildExpenseCard({required String uid, required String docId, required String title, required double amount, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') _showExpenseFormModal(uid: uid, docId: docId, currentTitle: title, currentAmount: amount);
                  if (value == 'delete') _deleteExpense(uid, docId);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 10), Text('Editar')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 10), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text('Q${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity, height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _payFixedExpense(uid, title, amount),
              icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
              label: const Text('Registrar Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
        ],
      ),
    );
  }
}