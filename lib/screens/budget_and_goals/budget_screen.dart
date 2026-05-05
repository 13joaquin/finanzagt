import 'package:finanzagt/screens/budget_and_goals/goals/fixed_expenses_screen.dart';
import 'package:finanzagt/screens/budget_and_goals/goals/flexible_expenses_screen.dart';
import 'package:finanzagt/screens/budget_and_goals/goals/savings_goals_screen.dart';
import 'package:finanzagt/screens/budget_and_goals/debts_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

// Providers
import '../../providers/user_provider.dart';
import '../../providers/transaction_provider.dart'; // <-- EL NUEVO JEFE ÚNICO
import '../../providers/GoalProvider.dart';
import '../../providers/debt_provider.dart';

// Widgets
import '../../widgets/budget_card.dart';
import '../../widgets/expense_pie_chart.dart';
import '../../widgets/budget_bar_chart.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Q');

    // 1. ESCUCHA DE PROVIDERS
    final userProvider = Provider.of<UserProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context); // Llamamos al jefe
    final goalProvider = Provider.of<GoalProvider>(context);
    final debtProvider = Provider.of<DebtProvider>(context);

    if (userProvider.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. CÁLCULOS DE LÓGICA (Basados en la realidad)
    final double income = transactionProvider.totalIncomes;

    // Filtramos los gastos fijos (Todo lo que NO sea Ocio/Flexible)
    final double fixed = transactionProvider.transactions
        .where((t) => t.type == 'expense' && t.category != 'Ocio/Flexible')
        .fold(0.0, (sum, item) => sum + item.amount);

    // Filtramos los gastos flexibles (Solo Ocio/Flexible)
    final double flexible = transactionProvider.transactions
        .where((t) => t.type == 'expense' && t.category == 'Ocio/Flexible')
        .fold(0.0, (sum, item) => sum + item.amount);

    final double savings = goalProvider.totalSaved;

    // Deudas
    final double paidDebts = debtProvider.totalPaidAmount;
    final double totalDebts = debtProvider.totalDebtAmount;

    // 3. LÍMITES AUTOMÁTICOS (Regla 50/30/20)
    final double limitNeeds = income * 0.50;
    final double limitWants = income * 0.30;
    final double limitSavings = income * 0.20;

    // 4. TOTALES Y PROGRESO
    final double totalSpent = fixed + flexible + savings + paidDebts;
    final double remaining = income - totalSpent;
    final double progressFactor = income > 0 ? (totalSpent / income).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Planificación", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // --- HEADER PROFESIONAL ---
          _buildHeader(context, income, remaining, progressFactor, currencyFormat),

          const SizedBox(height: 30),
          const Text("Categorías de Presupuesto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          // --- GRÁFICA DE PASTEL (NUEVO COMPONENTE) ---
          const ExpensePieChart(),
          const SizedBox(height: 30),

          // --- GRÁFICA DE BARRAS: PRESUPUESTO VS REAL ---
          BudgetBarChart(
            limitNeeds: limitNeeds,
            spentNeeds: fixed,
            limitWants: limitWants,
            spentWants: flexible,
            limitSavings: limitSavings,
            spentSavings: savings,
          ),
          const SizedBox(height: 30),

          const Text("Categorías de Presupuesto",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),

          // --- 1. TARJETA: GASTOS FIJOS ---
          BudgetCard(
            title: 'Gastos Fijos',
            subtitle: 'Necesidades (50%)',
            spent: fixed,
            total: limitNeeds, // Límite automático
            icon: Icons.home_work_outlined,
            color: const Color(0xFF4A47F6),
            actionLabel: 'Ver detalles',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FixedExpensesScreen()));
            },
          ),
          const SizedBox(height: 15),

          // --- 2. TARJETA: GASTOS FLEXIBLES ---
          BudgetCard(
            title: 'Gastos Flexibles',
            subtitle: 'Deseos y Ocio (30%)',
            spent: flexible,
            total: limitWants, // Límite automático
            icon: Icons.local_play_outlined,
            color: Colors.orange,
            actionLabel: 'Ver detalles',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FlexibleExpensesScreen()));
            },

          ),
          const SizedBox(height: 15),

          // --- 3. TARJETA: SANTUARIO (AHORRO) ---
          BudgetCard(
            title: 'Santuario',
            subtitle: 'Ahorros y Metas (20%)',
            spent: savings,
            total: limitSavings, // Límite automático
            icon: Icons.savings_outlined,
            color: const Color(0xFF2E7D32),
            actionLabel: 'Mis metas',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()));
            },
          ),
          const SizedBox(height: 15),

          // --- 4. TARJETA: MIS DEUDAS ---
          BudgetCard(
            title: 'Mis Deudas',
            subtitle: 'Recupera tu libertad financiera',
            spent: paidDebts,
            total: totalDebts,
            icon: Icons.credit_card_off_rounded,
            color: Colors.deepOrange,
            actionLabel: 'Gestionar deudas',
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtsScreen()));
            },
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, double income, double remaining, double progress, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A47F6), Color(0xFF6C63FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: const Color(0xFF4A47F6).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Presupuesto Mensual", style: TextStyle(color: Colors.white70, fontSize: 14)),
              IconButton(
                icon: const Icon(Icons.edit_note, color: Colors.white),
                onPressed: () {
                  // Futura función para ajustes
                },
              )
            ],
          ),
          Text(format.format(income),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _headerStat("Restante", format.format(remaining)),
              _headerStat("Progreso", "${(progress * 100).toStringAsFixed(0)}%"),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white24,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}