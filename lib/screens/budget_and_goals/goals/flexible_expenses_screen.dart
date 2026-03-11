import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FlexibleExpensesScreen extends StatefulWidget {
  const FlexibleExpensesScreen({super.key});

  @override
  State<FlexibleExpensesScreen> createState() => _FlexibleExpensesScreenState();
}

class _FlexibleExpensesScreenState extends State<FlexibleExpensesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  void _showAddExpenseModal() {
    _titleController.clear();
    _amountController.clear();
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Registrar Gasto de Ocio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: '¿En qué gastaste? (Ej. Cine, Café)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Monto (Q)', prefixIcon: const Icon(Icons.attach_money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  double amount = double.tryParse(_amountController.text) ?? 0;
                  if (_titleController.text.isEmpty || amount <= 0) return;

                  final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');

                  // Descontar del saldo seguro y patrimonio, y registrar transacción
                  await FirebaseFirestore.instance.runTransaction((tx) async {
                    var userSnap = await tx.get(userRef);
                    double safeBalance = (userSnap.data() as Map<String, dynamic>)['safe_balance'] ?? 0.0;
                    double netWorth = (userSnap.data() as Map<String, dynamic>)['net_worth'] ?? 0.0;

                    tx.update(userRef, {'safe_balance': safeBalance - amount, 'net_worth': netWorth - amount});
                    tx.set(userRef.collection('transactions').doc(), {
                      'title': _titleController.text, 'category': 'Ocio/Flexible', 'amount': amount, 'is_expense': true, 'date': FieldValue.serverTimestamp()
                    });
                  });
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Registrar Gasto', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Flexibles y Ocio', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.blueGrey[900], elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
        // QUITAMOS EL orderBy AQUÍ PARA EVITAR EL ERROR DE ÍNDICE DE FIREBASE
          stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').collection('transactions').where('category', isEqualTo: 'Ocio/Flexible').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            List<QueryDocumentSnapshot> expenses = snapshot.hasData ? snapshot.data!.docs : [];

            // ORDENAMOS POR FECHA DIRECTAMENTE EN DART
            expenses.sort((a, b) {
              Timestamp timeA = (a.data() as Map<String, dynamic>)['date'] ?? Timestamp.now();
              Timestamp timeB = (b.data() as Map<String, dynamic>)['date'] ?? Timestamp.now();
              return timeB.compareTo(timeA); // Orden descendente
            });

            double totalSpent = expenses.fold(0, (sum, doc) => sum + ((doc.data() as Map<String, dynamic>)['amount'] ?? 0));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ... (El código de la tarjeta naranja se queda igual) ...
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.orange, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text('TOTAL GASTADO EN OCIO', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Q${totalSpent.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Historial de Gustitos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                      TextButton.icon(onPressed: _showAddExpenseModal, icon: const Icon(Icons.add_circle, color: Colors.orange), label: const Text('Agregar', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)))
                    ],
                  ),
                  const SizedBox(height: 15),
                  if (expenses.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("Aún no tienes gastos de ocio", style: TextStyle(color: Colors.grey))))
                  else
                    ListView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        var data = expenses[index].data() as Map<String, dynamic>;
                        // CORRECCIÓN: AGREGAMOS .toStringAsFixed(2)
                        double amt = (data['amount'] ?? 0).toDouble();
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: const Icon(Icons.local_cafe, color: Colors.orange)),
                          title: Text(data['title'] ?? ''),
                          trailing: Text('Q${amt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
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