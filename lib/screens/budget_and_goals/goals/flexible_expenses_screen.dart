import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../../providers/user_provider.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';

class FlexibleExpensesScreen extends StatefulWidget {
  const FlexibleExpensesScreen({super.key});

  @override
  State<FlexibleExpensesScreen> createState() => _FlexibleExpensesScreenState();
}

class _FlexibleExpensesScreenState extends State<FlexibleExpensesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  final TransactionRepository _transactionRepo = TransactionRepository();

  Future<void> _saveFlexibleExpense(String uid) async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) return;

    try {
      // CORRECCIÓN: Usamos 'merchantName' en lugar de 'title'
      final newTransaction = TransactionModel(
        id: '',
        merchantName: title, // Aquí aplicamos la corrección
        amount: amount,
        type: 'expense',
        category: 'Ocio/Flexible',
        date: DateTime.now(),
      );

      await _transactionRepo.addTransaction(uid, newTransaction);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error guardando gasto flexible: $e");
    }
  }

  void _showAddExpenseModal(String uid) {
    _titleController.clear();
    _amountController.clear();

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
            const Text('Registrar Gasto de Ocio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: '¿En qué gastaste? (Ej. Cine, Café)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Monto (Q)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                onPressed: () => _saveFlexibleExpense(uid),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Guardar Gasto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final String uid = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gastos Flexibles (Ocio)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(uid)
              .collection('transactions')
              .where('category', isEqualTo: 'Ocio/Flexible')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return const Center(child: Text('Algo salió mal'));
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            final expenses = snapshot.data!.docs;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Historial de Ocio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton.icon(
                          onPressed: () => _showAddExpenseModal(uid),
                          icon: const Icon(Icons.add_circle, color: Colors.orange),
                          label: const Text('Agregar', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold))
                      )
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (expenses.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("Aún no tienes gastos de ocio", style: TextStyle(color: Colors.grey))))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        var data = expenses[index].data() as Map<String, dynamic>;
                        double amt = (data['amount'] ?? 0).toDouble();

                        // CORRECCIÓN: Leemos 'merchantName' (o 'title' por si acaso hay datos viejos guardados)
                        String displayName = data['merchantName'] ?? data['title'] ?? 'Sin nombre';

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(bottom: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
                          child: ListTile(
                            leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: const Icon(Icons.local_cafe, color: Colors.orange)),
                            title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                            trailing: Text('Q${amt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          }
      ),
    );
  }
}