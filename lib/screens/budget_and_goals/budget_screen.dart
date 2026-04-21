// Archivo: lib/screens/budget_and_goals/budget_screen.dart
import 'package:finanzagt/screens/budget_and_goals/goals/fixed_expenses_screen.dart';
import 'package:finanzagt/screens/budget_and_goals/goals/flexible_expenses_screen.dart';
import 'package:finanzagt/screens/budget_and_goals/goals/savings_goals_screen.dart';
import 'package:finanzagt/screens/budget_and_goals/debts_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../../providers/user_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expenseProvider.dart';
import '../../providers/GoalProvider.dart';
import '../../providers/debt_provider.dart';

// Widgets
import '../../widgets/budget_card.dart';

// Importa aquí tus pantallas reales cuando estén listas
// import 'goals/savings_goals_screen.dart';
// import 'goals/fixed_expenses_screen.dart';
// import 'goals/flexible_expenses_screen.dart';
// import '../budget_config_screen.dart';

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Verificación de usuario
    final userProvider = Provider.of<UserProvider>(context);
    if (userProvider.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Instancia de Providers
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final debtProvider = Provider.of<DebtProvider>(context);

    // 3. Cálculos de Deudas
    double totalDebts = debtProvider.debts.fold(0, (sum, d) => sum + d.totalAmount);
    double remainingDebts = debtProvider.debts.fold(0, (sum, d) => sum + d.remainingAmount);
    double paidDebts = totalDebts - remainingDebts;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Presupuesto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // Navegación a configuración
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Alerta si no ha configurado su sueldo
            if (budgetProvider.limitNeeds == 0)
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        "Toca el ícono de ⚙️ arriba a la derecha para configurar tu ingreso y activar tus límites.",
                        style: TextStyle(color: Colors.blue[800]),
                      ),
                    ),
                  ],
                ),
              ),

            // --- 1. TARJETA: GASTOS FIJOS ---
            BudgetCard(
              title: 'Gastos Fijos',
              subtitle: 'Necesidades (50%)',
              spent: expenseProvider.totalFixedAmount,
              total: budgetProvider.limitNeeds,
              icon: Icons.home_work_outlined,
              color: const Color(0xFF4A47F6),
              actionLabel: 'Ver detalles',
              onTap: () {
                // Navegación corregida (sin flecha =>)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FixedExpensesScreen()));
              },
            ),
            const SizedBox(height: 15),

            // --- 2. TARJETA: GASTOS FLEXIBLES ---
            BudgetCard(
              title: 'Gastos Flexibles',
              subtitle: 'Deseos y Ocio (30%)',
              spent: expenseProvider.totalFlexibleAmount,
              total: budgetProvider.limitWants,
              icon: Icons.shopping_bag_outlined,
              color: Colors.orange,
              actionLabel: 'Anotar gasto',
              onTap: () {
                // Navegación corregida (sin flecha =>)
                Navigator.push(context, MaterialPageRoute(builder: (context) => const FlexibleExpensesScreen()));
              },
            ),
            const SizedBox(height: 15),

            // --- 3. TARJETA: SANTUARIO (AHORRO) ---
            BudgetCard(
              title: 'Santuario',
              subtitle: 'Ahorros y Metas (20%)',
              spent: goalProvider.totalSaved,
              total: budgetProvider.limitSavings,
              icon: Icons.savings_outlined,
              color: const Color(0xFF2E7D32),
              actionLabel: 'Mis metas',
              onTap: () {
                // Navegación corregida
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
                // Navegación corregida
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DebtsScreen()));
              },
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}