import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../data/providers/budget_provider.dart';

class BudgetConfigScreen extends ConsumerStatefulWidget {
  const BudgetConfigScreen({super.key});

  @override
  ConsumerState<BudgetConfigScreen> createState() =>
      _BudgetConfigScreenState();
}

class _BudgetConfigScreenState extends ConsumerState<BudgetConfigScreen> {
  final TextEditingController _incomeController = TextEditingController();

  // Porcentajes estándar de la regla 50/30/20.
  static const double needsPercentage = 0.50;
  static const double wantsPercentage = 0.30;
  static const double savingsPercentage = 0.20;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentBudget() async {
    final uid = ref.read(userProvider)?.uid;

    if (uid == null) return;

    final budget = await ref
        .read(budgetProvider.notifier)
        .loadBudget(uid);

    if (!mounted || budget == null) return;

    setState(() {
      _incomeController.text =
          (budget['monthly_income'] ?? 0).toString();
    });
  }

  Future<void> _saveBudget(String uid) async {
    final income =
        double.tryParse(_incomeController.text.trim()) ?? 0;

    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un sueldo válido'),
        ),
      );
      return;
    }

    final success = await ref
        .read(budgetProvider.notifier)
        .saveBudget(
      uid: uid,
      monthlyIncome: income,
      limitNeeds: income * needsPercentage,
      limitWants: income * wantsPercentage,
      limitSavings: income * savingsPercentage,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Presupuesto configurado con éxito!',
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      final error =
          ref.read(budgetProvider).errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'No se pudo guardar el presupuesto.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(userProvider)?.uid;
    final isLoading = ref.watch(
      budgetProvider.select((state) => state.isLoading),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Configurar Mi Mes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Cuál es tu ingreso mensual?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _incomeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4A47F6),
              ),
              decoration: InputDecoration(
                prefixText: 'Q ',
                hintText: '0.00',
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 30),
            const Text(
              'Distribución Sugerida (50/30/20)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            _buildDistributionTile(
              'Necesidades (50%)',
              _calculateAmount(needsPercentage),
              Colors.blue,
              Icons.home,
            ),
            _buildDistributionTile(
              'Deseos/Ocio (30%)',
              _calculateAmount(wantsPercentage),
              Colors.orange,
              Icons.confirmation_number_outlined,
            ),
            _buildDistributionTile(
              'Ahorro/Metas (20%)',
              _calculateAmount(savingsPercentage),
              Colors.green,
              Icons.savings,
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: uid == null || isLoading
                    ? null
                    : () => _saveBudget(uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A47F6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(
                  color: Colors.white,
                )
                    : const Text(
                  'Establecer Presupuesto',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
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

  double _calculateAmount(double percentage) {
    final income =
        double.tryParse(_incomeController.text.trim()) ?? 0;

    return income * percentage;
  }

  Widget _buildDistributionTile(
      String title,
      double amount,
      Color color,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            'Q${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}