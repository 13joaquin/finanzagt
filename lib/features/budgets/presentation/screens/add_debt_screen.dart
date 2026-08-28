import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../goals/data/providers/debt_provider.dart';

class AddDebtScreen extends ConsumerStatefulWidget {
  const AddDebtScreen({super.key});

  @override
  ConsumerState<AddDebtScreen> createState() => _AddDebtScreenState();
}

class _AddDebtScreenState extends ConsumerState<AddDebtScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _totalAmountController =
  TextEditingController();
  final TextEditingController _monthlyPaymentController =
  TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _totalAmountController.dispose();
    _monthlyPaymentController.dispose();
    super.dispose();
  }

  Future<void> _saveDebt() async {
    final name = _nameController.text.trim();
    final totalAmount =
    double.tryParse(_totalAmountController.text.trim());

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa a quién le debes'),
        ),
      );
      return;
    }

    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un monto total válido'),
        ),
      );
      return;
    }

    await ref.read(debtProvider.notifier).addDebt(
      name: name,
      totalAmount: totalAmount,
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nueva Deuda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '¿A quién le debes?',
                hintText: 'Ej. Banco Industrial',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _totalAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monto Total de la Deuda',
                prefixText: 'Q ',
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _monthlyPaymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cuota Mensual (Opcional)',
                prefixText: 'Q ',
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                onPressed: _saveDebt,
                child: const Text(
                  'Guardar Deuda',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}