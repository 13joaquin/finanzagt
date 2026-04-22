// Archivo: lib/screens/dashboard/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // Gráficos de Flujo de Caja
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

// --- NUEVOS PROVIDERS (Reemplazan a TransactionProvider) ---
import '../../providers/user_provider.dart';
import '../../providers/budget_provider.dart';
import '../../providers/expenseProvider.dart'; // Asegúrate de que el nombre de este archivo sea exacto
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
    final Color greenColor = const Color(0xFF2E7D32);
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- 1. CABECERA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, ${currentUser.displayName ?? "Usuario"}',
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        Text('Tu panorama financiero hoy', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                      child: CircleAvatar(radius: 24, backgroundColor: Colors.grey[200], child: Icon(Icons.person, color: Colors.grey[600], size: 30)),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // --- 2. EL GRAN CABLEADO DEL DASHBOARD (CONSUMER DOBLE) ---
                Consumer2<BudgetProvider, ExpenseProvider>(
                  builder: (context, budget, expense, child) {

                    // SOLUCIÓN ERROR 1:
                    // Cambia "monthlyIncome" por el nombre exacto que tengas en tu BudgetProvider
                    // (Ej. budget.income, budget.totalBudget, budget.ingresoMensual)
                    double totalIncome = budget.monthlyIncome;

                    double totalExpenses = expense.totalFixedAmount + expense.totalFlexibleAmount;
                    double safeToSpend = totalIncome - totalExpenses;

                    List<ExpenseModel> allActivity = [...expense.fixedExpenses, ...expense.flexibleExpenses];
                    allActivity.sort((a, b) => b.date.compareTo(a.date));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: safeToSpend >= 0 ? greenColor : Colors.redAccent,
                                      borderRadius: BorderRadius.circular(16)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('SEGURO PARA GASTAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                      Text('Q${currencyFormat.format(safeToSpend)}',
                                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('INGRESOS DEL MES', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
                                    Text('Q${currencyFormat.format(totalIncome)}',
                                        style: TextStyle(color: Colors.blueGrey[900], fontSize: 18, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        _buildChart(totalIncome, totalExpenses, greenColor),

                        const SizedBox(height: 25),
                        Text('Actividad Reciente', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        const SizedBox(height: 15),

                        if (allActivity.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No hay movimientos registrados", style: TextStyle(color: Colors.grey))))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allActivity.length > 5 ? 5 : allActivity.length,
                            itemBuilder: (context, index) {
                              final item = allActivity[index];

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: _buildTransactionItem(
                                  // SOLUCIÓN ERROR 2:
                                  // Asumimos que se llama "name". Si te sigue dando error,
                                  // revisa tu expense_model.dart. Podría ser "description" o "merchantName".
                                  title: item.name,

                                  subtitle: "${item.category} • ${DateFormat('dd/MM').format(item.date)}",
                                  amount: "-Q${currencyFormat.format(item.amount)}",
                                  icon: Icons.arrow_outward_rounded,
                                  iconColor: Colors.redAccent,
                                  isExpense: true,
                                ),
                              );
                            },
                          ),
                        const SizedBox(height: 80),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets de apoyo ---
  Widget _buildChart(double income, double expense, Color green) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (income > expense ? income : expense) * 1.2 + 100, // Margen superior
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: income, color: green, width: 30)]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: expense, color: Colors.orange, width: 30)]),
        ],
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v == 0 ? 'In' : 'Out', style: const TextStyle(fontSize: 10)))),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
      )),
    );
  }

  Widget _buildTransactionItem({required String title, required String subtitle, required String amount, required IconData icon, required Color iconColor, required bool isExpense}) {
    return Card(
      margin: EdgeInsets.zero, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.1), child: Icon(icon, color: iconColor, size: 18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isExpense ? Colors.black : Colors.green[700])),
      ),
    );
  }
}