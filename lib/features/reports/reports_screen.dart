import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import '../transactions/data/models/transaction_model.dart';
import '../transactions/data/providers/transaction_provider.dart';

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionProvider);

    final double totalIncome = _getTotalIncome(transactions);
    final double totalExpense = _getTotalExpense(transactions);

    final currencyFormat = NumberFormat.simpleCurrency(
      decimalDigits: 2,
      name: 'Q',
    );

    final int healthScore = _getHealthScore(
      totalIncome,
      totalExpense,
    );

    final Map<String, double> categoriesData =
    _getCategoryData(transactions);

    final List<TransactionModel> topExpenses =
    _getTopExpenses(transactions);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Informes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHealthCard(healthScore),

            const SizedBox(height: 25),

            const Text(
              'Distribución por Categoría',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildPieChartCard(categoriesData),

            const SizedBox(height: 25),

            const Text(
              'Ingresos vs Gastos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildBarChartCard(
              totalIncome,
              totalExpense,
            ),

            const SizedBox(height: 25),

            const Text(
              'Gastos más significativos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _buildInsightsList(
              topExpenses,
              currencyFormat,
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  double _getTotalIncome(List<TransactionModel> transactions) {
    return transactions
        .where((transaction) => transaction.type == 'income')
        .fold(
      0.0,
          (total, transaction) => total + transaction.amount,
    );
  }

  double _getTotalExpense(List<TransactionModel> transactions) {
    return transactions
        .where((transaction) => transaction.type == 'expense')
        .fold(
      0.0,
          (total, transaction) => total + transaction.amount,
    );
  }

  int _getHealthScore(
      double totalIncome,
      double totalExpense,
      ) {
    if (totalIncome <= 0) {
      return 0;
    }

    final double ratio = totalExpense / totalIncome;

    return ((1 - ratio) * 100)
        .clamp(0, 100)
        .toInt();
  }

  Map<String, double> _getCategoryData(
      List<TransactionModel> transactions,
      ) {
    final Map<String, double> data = {};

    for (final transaction
    in transactions.where((t) => t.type == 'expense')) {
      data[transaction.category] =
          (data[transaction.category] ?? 0) +
              transaction.amount;
    }

    return data;
  }

  List<TransactionModel> _getTopExpenses(
      List<TransactionModel> transactions,
      ) {
    final List<TransactionModel> expenses = transactions
        .where((transaction) => transaction.type == 'expense')
        .toList();

    expenses.sort(
          (a, b) => b.amount.compareTo(a.amount),
    );

    return expenses.take(3).toList();
  }

  Widget _buildHealthCard(int score) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: score > 60
              ? [
            const Color(0xFF4A47F6),
            const Color(0xFF7673FF),
          ]
              : [
            Colors.orange,
            Colors.redAccent,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Salud Financiera',
                style: TextStyle(
                  color: Colors.white70,
                ),
              ),
              Text(
                score > 60
                    ? '¡Buen progreso!'
                    : 'Alerta de gastos',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            '$score/100',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    final String cat = category.toLowerCase();

    if (cat.contains('comida') ||
        cat.contains('transporte') ||
        cat.contains('vivienda') ||
        cat.contains('ocio')) {
      return Colors.orange;
    }

    if (cat.contains('ahorro') ||
        cat.contains('meta')) {
      return Colors.green;
    }

    if (cat.contains('deuda') ||
        cat.contains('préstamo') ||
        cat.contains('tarjeta')) {
      return Colors.redAccent;
    }

    return const Color(0xFF4A47F6);
  }

  Widget _buildPieChartCard(
      Map<String, double> data,
      ) {
    return Container(
      height: 250,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: data.isEmpty
          ? const Center(
        child: Text(
          'Registra un gasto para ver tu gráfica',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      )
          : PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 40,
          sections: data.entries.map(
                (entry) {
              return PieChartSectionData(
                value: entry.value,
                title: entry.key,
                radius: 50,
                titleStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                color: _getCategoryColor(entry.key),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildBarChartCard(
      double income,
      double expense,
      ) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: BarChart(
        BarChartData(
          borderData: FlBorderData(
            show: false,
          ),
          titlesData: FlTitlesData(
            show: false,
          ),
          barGroups: [
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: income,
                  color: Colors.green,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
                BarChartRodData(
                  toY: expense,
                  color: Colors.redAccent,
                  width: 20,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsList(
      List<TransactionModel> expenses,
      NumberFormat format,
      ) {
    return Column(
      children: expenses
          .map(
            (transaction) => Card(
          margin: const EdgeInsets.only(
            bottom: 10,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Color(0xFFF0F0FF),
              child: Icon(
                Icons.trending_up,
                color: Color(0xFF4A47F6),
              ),
            ),
            title: Text(
              transaction.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              transaction.category,
            ),
            trailing: Text(
              format.format(transaction.amount),
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      )
          .toList(),
    );
  }
}