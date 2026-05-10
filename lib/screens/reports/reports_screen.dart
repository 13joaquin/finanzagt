import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/transaction_model.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final currencyFormat = NumberFormat.simpleCurrency(decimalDigits: 2, name: 'Q');

    // 1. Cálculos de datos reales
    final double totalIncome = txProvider.totalIncomes;
    final double totalExpense = txProvider.totalExpenses;

    // Solución al error: Calculamos la salud financiera localmente (0 a 100)
    // Si gastas menos del 70% de tus ingresos, tienes buena salud.
    int healthScore = 0;
    if (totalIncome > 0) {
      double ratio = totalExpense / totalIncome;
      healthScore = ((1 - ratio) * 100).clamp(0, 100).toInt();
    }

    final Map<String, double> categoriesData = _getCategoryData(txProvider.transactions);
    final List<TransactionModel> topExpenses = _getTopExpenses(txProvider.transactions);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Informes", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Resumen de Salud (Calculado dinámicamente)
            _buildHealthCard(healthScore),

            const SizedBox(height: 25),
            const Text("Distribución por Categoría", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 2. Gráfica de Pastel Real (fl_chart)
            _buildPieChartCard(categoriesData),

            const SizedBox(height: 25),
            const Text("Comparativa Mensual", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 3. Gráfica de Barras Real (fl_chart)
            _buildBarChartCard(totalIncome, totalExpense),

            const SizedBox(height: 25),
            const Text("Gastos más significativos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 4. Lista de Insights
            _buildInsightsList(topExpenses, currencyFormat),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- Lógica de Datos ---

  Map<String, double> _getCategoryData(List<TransactionModel> txs) {
    Map<String, double> data = {};
    for (var tx in txs.where((t) => t.type == 'expense')) {
      data[tx.category] = (data[tx.category] ?? 0) + tx.amount;
    }
    return data;
  }

  List<TransactionModel> _getTopExpenses(List<TransactionModel> txs) {
    var expenses = txs.where((t) => t.type == 'expense').toList();
    expenses.sort((a, b) => b.amount.compareTo(a.amount));
    return expenses.take(3).toList();
  }

  // --- Widgets de Interfaz ---

  Widget _buildHealthCard(int score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: score > 60 ? [const Color(0xFF4A47F6), const Color(0xFF7673FF)] : [Colors.orange, Colors.redAccent],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Salud Financiera", style: TextStyle(color: Colors.white70)),
              Text(score > 60 ? "¡Buen progreso!" : "Alerta de gastos",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            ],
          ),
          Text("$score/100", style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- NUEVA FUNCIÓN: Asigna el color de la cubeta según la categoría ---
  Color _getCategoryColor(String category) {
    // Convertimos a minúsculas para evitar errores de escritura
    final cat = category.toLowerCase();

    // Cubeta 1: Supervivencia (Naranja)
    if (cat.contains('comida') || cat.contains('transporte') || cat.contains('vivienda') || cat.contains('ocio')) {
      return Colors.orange;
    }
    // Cubeta 2: Santuario (Verde) - Por si en el futuro agregas esta categoría de gasto
    else if (cat.contains('ahorro') || cat.contains('meta')) {
      return Colors.green;
    }
    // Cubeta 3: Deudas (Rojo) - Por si registras el pago de una deuda como gasto
    else if (cat.contains('deuda') || cat.contains('préstamo') || cat.contains('tarjeta')) {
      return Colors.redAccent;
    }
    // Otros Gastos (Azul u otro color neutro)
    else {
      return const Color(0xFF4A47F6);
    }
  }

  // --- WIDGET ACTUALIZADO ---
  Widget _buildPieChartCard(Map<String, double> data) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: data.isEmpty
          ? const Center(child: Text("Registra un gasto para ver tu gráfica", style: TextStyle(color: Colors.grey)))
          : PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: data.entries.map((e) {
            return PieChartSectionData(
              value: e.value,
              title: e.key,
              radius: 50,
              titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
              // Usamos nuestra nueva función mágica aquí:
              color: _getCategoryColor(e.key),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBarChartCard(double income, double expense) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(show: false),
          barGroups: [
            BarChartGroupData(x: 0, barRods: [
              BarChartRodData(toY: income, color: Colors.green, width: 20, borderRadius: BorderRadius.circular(4)),
              BarChartRodData(toY: expense, color: Colors.redAccent, width: 20, borderRadius: BorderRadius.circular(4)),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsList(List<TransactionModel> expenses, NumberFormat format) {
    return Column(
      children: expenses.map((tx) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: const CircleAvatar(backgroundColor: Color(0xFFF0F0FF), child: Icon(Icons.trending_up, color: Color(0xFF4A47F6))),
          title: Text(tx.name, style: const TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text(tx.category),
          trailing: Text(format.format(tx.amount), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      )).toList(),
    );
  }
}