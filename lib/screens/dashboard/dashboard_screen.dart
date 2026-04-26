// Archivo: lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Importamos los nuevos "motores"
import '../../providers/user_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expenseProvider.dart';
import '../../data/models/expense_model.dart';

import '../profile/profile_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  Widget build(BuildContext context) {
    // 1. ESCUCHAMOS LOS PROVIDERS (Aquí es donde ocurre la magia)
    final userProvider = Provider.of<UserProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. CÁLCULOS EN TIEMPO REAL
    double income = budgetProvider.monthlyIncome;
    // Sumamos todos los gastos (fijos + flexibles)
    double totalExpenses = expenseProvider.totalFixedExpenses + expenseProvider.totalFlexibleExpenses;
    double netWorth = income - totalExpenses;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(userProvider),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARJETA DE PATRIMONIO NETO
            _buildNetWorthCard(netWorth),
            const SizedBox(height: 25),

            // FILA DE RESUMEN (INGRESOS VS GASTOS)
            Row(
              children: [
                Expanded(child: _buildStatCard("Ingresos", income, Colors.green)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("Gastos", totalExpenses, Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 30),

            const Text("Flujo de Caja", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildCashFlowChart(income, totalExpenses),

            const SizedBox(height: 30),
            const Text("Actividad Reciente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // LISTA DE ACTIVIDAD (Usando los gastos del provider)
            _buildRecentActivity(expenseProvider.expenses),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DE LA INTERFAZ ---

  Widget _buildNetWorthCard(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF4A47F6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF4A47F6).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text("Patrimonio Neto", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          Text("Q${currencyFormat.format(amount)}",
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Q${currencyFormat.format(amount)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCashFlowChart(double inAmt, double outAmt) {
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (inAmt > outAmt ? inAmt : outAmt) * 1.2,
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: inAmt, color: Colors.green, width: 25, borderRadius: BorderRadius.circular(6))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: outAmt, color: Colors.redAccent, width: 25, borderRadius: BorderRadius.circular(6))]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v == 0 ? 'Entrada' : 'Salida', style: const TextStyle(fontSize: 12)))),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(List<ExpenseModel> expenses) {
    if (expenses.isEmpty) {
      return const Center(child: Text("No hay movimientos este mes", style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: expenses.length > 5 ? 5 : expenses.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = expenses[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: (item.isFixed ? Colors.orange : Colors.blue).withOpacity(0.1),
            child: Icon(item.isFixed ? Icons. push_pin : Icons.shopping_bag, color: item.isFixed ? Colors.orange : Colors.blue, size: 18),
          ),
          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(DateFormat('dd MMM').format(item.date)),
          trailing: Text("-Q${currencyFormat.format(item.amount)}", style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(UserProvider userProvider) {
    // Obtenemos el nombre del usuario o un "Hola" por defecto
    final String userName = userProvider.currentUser?.displayName ?? "Usuario";

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hola,", style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () async {
            // Lógica para cerrar sesión
            await FirebaseAuth.instance.signOut();
          },
        ),
      ],
    );
  }
}