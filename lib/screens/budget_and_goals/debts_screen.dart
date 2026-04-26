import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/debt_provider.dart';
import '../../data/models/debt_model.dart';

class DebtsScreen extends StatelessWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final debtProvider = Provider.of<DebtProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Mis Deudas (Piedras)")),
      body: debtProvider.debts.isEmpty
          ? const Center(child: Text("¡No tienes deudas! Tu Santuario está ligero."))
          : ListView.builder(
        itemCount: debtProvider.debts.length,
        itemBuilder: (context, index) {
          final debt = debtProvider.debts[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(debt.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("Q${debt.remainingAmount.toStringAsFixed(2)}", style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Barra de progreso usando el modelo
                  LinearProgressIndicator(
                    value: debt.paymentProgress,
                    backgroundColor: Colors.grey[200],
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _showPaymentDialog(context, debt, debtProvider),
                    child: const Text("Abonar Cuota"),
                  )
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context, debtProvider),
        child: const Icon(Icons.add),
      ),
    );
  }

  // --- Lógica de los Diálogos ---
  void _showAddDebtDialog(BuildContext context, DebtProvider provider) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nueva Deuda"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nombre o Banco")),
            TextField(controller: amountController, decoration: const InputDecoration(labelText: "Monto Total"), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              provider.addDebt(name: nameController.text, totalAmount: double.parse(amountController.text));
              Navigator.pop(context);
            },
            child: const Text("Guardar"),
          )
        ],
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, DebtModel debt, DebtProvider provider) {
    final amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Abonar a ${debt.name}"),
        content: TextField(controller: amountController, decoration: const InputDecoration(labelText: "Monto del abono"), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            onPressed: () {
              provider.payDebt(debt.id, double.parse(amountController.text));
              Navigator.pop(context);
            },
            child: const Text("Confirmar Pago"),
          )
        ],
      ),
    );
  }
}