// lib/screens/presentation/budget_screen.dart
import 'package:finanzagt/features/budgets/presentation/screens/debts_screen.dart';
import 'package:finanzagt/features/budgets/presentation/screens/fixed_expenses_screen.dart';
import 'package:finanzagt/features/budgets/presentation/screens/flexible_expenses_screen.dart';
import 'package:finanzagt/screens/budget_and_goals/presentation/savings_goals_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../screens/transactions/data/providers/transaction_provider.dart';
import '../../../../screens/goals/data/providers/GoalProvider.dart';
import '../../../../screens/goals/data/providers/debt_provider.dart';
import '../../../../widgets/budget_card.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  // MÉTODO PARA MOSTRAR EL SELECTOR DE DETALLES
  void _showSupervivenciaMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "¿Qué deseas revisar?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.lock_outline, color: Colors.orange),
                ),
                title: const Text("Gastos Fijos", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Renta, servicios, compromisos mensuales"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FixedExpensesScreen()));
                },
              ),
              const Divider(height: 30),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.shopping_bag_outlined, color: Colors.orange),
                ),
                title: const Text("Gastos Flexibles", style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Comida, ocio, gastos variables"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const FlexibleExpensesScreen()));
                },
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Q');

    final txProvider = Provider.of<TransactionProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final debtProvider = Provider.of<DebtProvider>(context);

    // LÓGICA DE FUSIÓN DE DATOS
    double ingresos = txProvider.totalIncomes;

    // Filtramos los gastos para la Cubeta de Supervivencia
    final double gastosFijos = txProvider.transactions
        .where((t) => t.type == 'expense' && t.isFixed == true)
        .fold(0.0, (sum, item) => sum + item.amount);

    final double gastosFlexibles = txProvider.transactions
        .where((t) => t.type == 'expense' && t.isFixed == false)
        .fold(0.0, (sum, item) => sum + item.amount);

    double totalSupervivencia = gastosFijos + gastosFlexibles;

    // Definimos un presupuesto ideal (ejemplo: 50% de ingresos)
    double metaSupervivencia = ingresos > 0 ? ingresos * 0.5 : 1000.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(ingresos, txProvider.totalExpenses, format),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const Text("Tus Cubetas Financieras",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),

                // CUBETA 1: SUPERVIVENCIA
                BudgetCard(
                  title: "Supervivencia",
                  subtitle: "Fijos (Q${gastosFijos.toStringAsFixed(0)}) + Flexibles (Q${gastosFlexibles.toStringAsFixed(0)})",
                  spent: totalSupervivencia,
                  total: metaSupervivencia,
                  icon: Icons.home_repair_service_outlined,
                  color: Colors.orange,
                  actionLabel: "Ver detalles",
                  onTap: () => _showSupervivenciaMenu(context), // <--- ACCIÓN CORREGIDA
                ),
                const SizedBox(height: 15),

                // CUBETA 2: EL SANTUARIO
                BudgetCard(
                  title: "El Santuario",
                  subtitle: "Tus Metas de Ahorro",
                  spent: goalProvider.totalSaved,
                  total: goalProvider.totalTarget > 0 ? goalProvider.totalTarget : 1.0,
                  icon: Icons.eco_outlined,
                  color: Colors.green,
                  actionLabel: "Ir al Santuario",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()));
                  },
                ),
                const SizedBox(height: 15),

                // CUBETA 3: DEUDAS / FUTURO
                BudgetCard(
                  title: "Deudas",
                  subtitle: "Pendiente por pagar",
                  spent: debtProvider.totalPaidAmount,
                  total: debtProvider.totalInitialDebt > 0 ? debtProvider.totalInitialDebt : 1.0,
                  icon: Icons.money_off_csred_outlined,
                  color: Colors.redAccent,
                  actionLabel: "Gestionar Deudas",
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtsScreen()));
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Se mantiene tu diseño UI original del Header
  Widget _buildHeader(double income, double spent, NumberFormat format) {
    double remaining = income - spent;
    double progress = income > 0 ? (spent / income).clamp(0, 1) : 0;
    // ... tu implementación de diseño actual ...
    return Container(); // Placeholder para mantener la estructura
  }
}