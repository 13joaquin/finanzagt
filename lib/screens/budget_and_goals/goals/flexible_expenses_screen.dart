import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Importamos los NUEVOS motores y modelos
import '../../../providers/user_provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_model.dart';

class FlexibleExpensesScreen extends StatefulWidget {
  const FlexibleExpensesScreen({super.key});

  @override
  State<FlexibleExpensesScreen> createState() => _FlexibleExpensesScreenState();
}

class _FlexibleExpensesScreenState extends State<FlexibleExpensesScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // Función para guardar el gasto usando el NUEVO TransactionProvider
  Future<void> _saveFlexibleExpense(String uid) async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty || amountText.isEmpty) return;

    final amount = double.tryParse(amountText) ?? 0.0;
    if (amount <= 0) return;

    try {
      // 1. Creamos el registro en el formato maestro
      final newTransaction = TransactionModel(
        id: '', // Firebase genera el ID automáticamente
        name: title,
        amount: amount,
        date: DateTime.now(),
        type: 'expense', // Es un gasto
        category: 'Ocio/Flexible', // Etiqueta para saber que es flexible
      );

      // 2. Llamamos al TransactionProvider para agregarlo
      await Provider.of<TransactionProvider>(context, listen: false).addTransaction(newTransaction);

      if (mounted) {
        _titleController.clear();
        _amountController.clear();
        Navigator.pop(context); // Cerramos el formulario al terminar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gasto flexible registrado con éxito")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final uid = userProvider.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Gastos Flexibles (Deseos)", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      // Cambiamos el Consumer al TransactionProvider
      body: Consumer<TransactionProvider>(
        builder: (context, transactionProvider, child) {
          // Filtramos la lista principal para mostrar SOLO los gastos flexibles
          final expenses = transactionProvider.transactions
              .where((t) => t.type == 'expense' && t.category == 'Ocio/Flexible')
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddExpenseForm(uid),
                const SizedBox(height: 30),
                const Text("Historial de este mes",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                if (expenses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text("No hay gastos registrados aún.", style: TextStyle(color: Colors.grey)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final item = expenses[index];

                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(color: Colors.grey.withOpacity(0.1))
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                              backgroundColor: Colors.orange.withOpacity(0.1),
                              child: const Icon(Icons.local_cafe, color: Colors.orange)
                          ),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: const Text("Gasto Flexible"),
                          trailing: Text(
                              'Q${item.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddExpenseForm(String? uid) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "¿En qué gastaste?", border: InputBorder.none),
          ),
          const Divider(),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: "Monto (Q)", border: InputBorder.none),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: uid == null ? null : () => _saveFlexibleExpense(uid),
              child: const Text("Registrar Gasto", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}