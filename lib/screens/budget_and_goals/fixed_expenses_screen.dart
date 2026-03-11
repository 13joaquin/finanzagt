import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FixedExpensesScreen extends StatefulWidget {
  const FixedExpensesScreen({super.key});

  @override
  State<FixedExpensesScreen> createState() => _FixedExpensesScreenState();
}

class _FixedExpensesScreenState extends State<FixedExpensesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // ==========================================
  // LÓGICA: CREAR O EDITAR GASTO FIJO
  // ==========================================
  void _showExpenseFormModal({String? docId, String? currentTitle, double? currentAmount}) {
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
            Text(docId == null ? 'Agregar Gasto Recurrente' : 'Editar Gasto', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Nombre (Ej. Luz, Alquiler)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Monto a pagar (Q)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
                  double amount = double.parse(_amountController.text);

                  final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');
                  if (docId == null) {
                    await userRef.collection('fixed_expenses').add({
                      'title': _titleController.text,
                      'amount': amount,
                    });
                  } else {
                    await userRef.collection('fixed_expenses').doc(docId).update({
                      'title': _titleController.text,
                      'amount': amount,
                    });
                  }
                  if (mounted) Navigator.pop(context);
                },
                child: Text(docId == null ? 'Guardar Gasto Fijo' : 'Actualizar', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LÓGICA: EJECUTAR PAGO DEL GASTO FIJO
  // ==========================================
  void _payFixedExpense(String title, double amount) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');

    try {
      await FirebaseFirestore.instance.runTransaction((tx) async {
        var userSnap = await tx.get(userRef);
        double safeBalance = (userSnap.data() as Map<String, dynamic>)['safe_balance'] ?? 0.0;
        double netWorth = (userSnap.data() as Map<String, dynamic>)['net_worth'] ?? 0.0;

        if (safeBalance < amount) throw Exception("Fondos insuficientes");

        // Descuenta el dinero de tus saldos reales
        tx.update(userRef, {
          'safe_balance': safeBalance - amount,
          'net_worth': netWorth - amount
        });

        // Lo agrega a tu Actividad (Transacciones)
        tx.set(userRef.collection('transactions').doc(), {
          'title': 'Pago de factura: $title',
          'category': 'Gastos Fijos',
          'amount': amount,
          'is_expense': true,
          'date': FieldValue.serverTimestamp()
        });
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Pago de $title ejecutado con éxito'), backgroundColor: Colors.green));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No tienes suficiente Saldo Seguro'), backgroundColor: Colors.red));
    }
  }

  // ==========================================
  // LÓGICA: ELIMINAR GASTO DE LA LISTA
  // ==========================================
  void _deleteExpense(String docId) async {
    await FirebaseFirestore.instance.collection('users').doc('test_user_123').collection('fixed_expenses').doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    final Color blueColor = Colors.blue;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Gastos Fijos y Hogar', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.blueGrey[900], elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').collection('fixed_expenses').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            List<QueryDocumentSnapshot> expenses = snapshot.hasData ? snapshot.data!.docs : [];

            // Calculamos el total de gastos fijos
            double totalFixed = 0;
            for (var doc in expenses) {
              totalFixed += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TARJETA TOTAL GASTOS FIJOS
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: blueColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text('TOTAL GASTOS FIJOS DEL MES', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Q${totalFixed.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // MIS GASTOS RECURRENTES Y BOTÓN AGREGAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gastos Recurrentes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                      TextButton.icon(
                        onPressed: () => _showExpenseFormModal(),
                        icon: Icon(Icons.add_circle, color: blueColor),
                        label: Text('Agregar nuevo', style: TextStyle(color: blueColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // LISTA INFINITA DE GASTOS FIJOS
                  if (expenses.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No tienes gastos fijos registrados", style: TextStyle(color: Colors.grey))))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        var doc = expenses[index];
                        var data = doc.data() as Map<String, dynamic>;
                        String title = data['title'] ?? 'Sin título';
                        double amount = (data['amount'] ?? 0).toDouble();

                        return _buildExpenseCard(docId: doc.id, title: title, amount: amount, color: blueColor);
                      },
                    ),
                ],
              ),
            );
          }
      ),
    );
  }

  // WIDGET DE LA TARJETA DEL GASTO FIJO
  Widget _buildExpenseCard({required String docId, required String title, required double amount, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.receipt_long, color: color)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Monto: Q${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, color: Colors.grey[800], fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              // MENÚ DE 3 PUNTOS
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') _showExpenseFormModal(docId: docId, currentTitle: title, currentAmount: amount);
                  if (value == 'delete') _deleteExpense(docId);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 10), Text('Editar')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 10), Text('Eliminar', style: TextStyle(color: Colors.red))])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),

          // BOTÓN DE PAGAR
          SizedBox(
            width: double.infinity, height: 40,
            child: ElevatedButton.icon(
              onPressed: () => _payFixedExpense(title, amount),
              icon: const Icon(Icons.check_circle_outline, size: 18, color: Colors.white),
              label: const Text('Registrar Pago', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          )
        ],
      ),
    );
  }
}