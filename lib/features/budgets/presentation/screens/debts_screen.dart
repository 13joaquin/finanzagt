import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../goals/data/models/debt_model.dart';
import '../../../goals/data/providers/debt_provider.dart';


class DebtsScreen extends ConsumerWidget {
  const DebtsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Deudas (Piedras)'),
      ),
      body: debts.isEmpty
          ? const Center(
        child: Text(
          '¡No tienes deudas! Tu Santuario está ligero.',
        ),
      )
          : ListView.builder(
        itemCount: debts.length,
        itemBuilder: (context, index) {
          final debt = debts[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          debt.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Q${debt.remainingAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  LinearProgressIndicator(
                    value: debt.paymentProgress,
                    backgroundColor: Colors.grey[200],
                    color: Colors.deepOrange,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _showPaymentDialog(
                      context,
                      debt,
                      ref,
                    ),
                    child: const Text('Abonar Cuota'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddDebtDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDebtDialog(
      BuildContext context,
      WidgetRef ref,
      ) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nueva Deuda'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre o Banco',
                ),
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Monto Total',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final amount = double.tryParse(
                  amountController.text.trim(),
                );

                if (name.isEmpty ||
                    amount == null ||
                    amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ingresa un nombre y un monto válido.',
                      ),
                    ),
                  );
                  return;
                }

                ref.read(debtProvider.notifier).addDebt(
                  name: name,
                  totalAmount: amount,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  void _showPaymentDialog(
      BuildContext context,
      DebtModel debt,
      WidgetRef ref,
      ) {
    final amountController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Abonar a ${debt.name}'),
          content: TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Monto del abono',
            ),
            keyboardType: TextInputType.number,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(
                  amountController.text.trim(),
                );

                if (amount == null || amount <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Ingresa un monto de abono válido.',
                      ),
                    ),
                  );
                  return;
                }

                ref.read(debtProvider.notifier).payDebt(
                  debt.id,
                  amount,
                  debt.name,
                );

                Navigator.pop(dialogContext);
              },
              child: const Text('Confirmar Pago'),
            ),
          ],
        );
      },
    );
  }
}