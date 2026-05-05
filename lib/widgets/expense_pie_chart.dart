import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../data/models/transaction_model.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Escuchamos al "Jefe Único" (TransactionProvider)
    final txProvider = Provider.of<TransactionProvider>(context);
    final transactions = txProvider.transactions;

    // 2. Filtramos solo los gastos para la gráfica
    final expenses = transactions.where((t) => t.type == 'expense').toList();

    if (expenses.isEmpty) {
      return const Center(
          child: Text("No hay gastos registrados este mes",
              style: TextStyle(color: Colors.grey))
      );
    }

    // 3. Agrupamos montos por categoría
    Map<String, double> dataMap = {};
    for (var tx in expenses) {
      dataMap[tx.category] = (dataMap[tx.category] ?? 0) + tx.amount;
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: _showingSections(dataMap),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Leyenda dinámica
        _buildLegend(dataMap),
      ],
    );
  }

  // Genera las "rebanadas" del pastel dinámicamente
  List<PieChartSectionData> _showingSections(Map<String, double> dataMap) {
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.amber
    ];
    int index = 0;

    return dataMap.entries.map((entry) {
      final color = colors[index % colors.length];
      index++;
      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '', // No ponemos título dentro para que no se amontone
        radius: 50,
      );
    }).toList();
  }

  // Widget para mostrar qué significa cada color
  Widget _buildLegend(Map<String, double> dataMap) {
    final List<Color> colors = [
      Colors.blue, Colors.red, Colors.green, Colors.orange,
      Colors.purple, Colors.teal, Colors.amber
    ];
    int index = 0;

    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: dataMap.entries.map((entry) {
        final color = colors[index % colors.length];
        index++;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 12, height: 12, color: color),
            const SizedBox(width: 4),
            Text("${entry.key}: Q${entry.value.toStringAsFixed(0)}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        );
      }).toList(),
    );
  }
}