import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class BudgetBarChart extends StatelessWidget {
  final double limitNeeds;
  final double spentNeeds;
  final double limitWants;
  final double spentWants;
  final double limitSavings;
  final double spentSavings;

  const BudgetBarChart({
    super.key,
    required this.limitNeeds,
    required this.spentNeeds,
    required this.limitWants,
    required this.spentWants,
    required this.limitSavings,
    required this.spentSavings,
  });

  @override
  Widget build(BuildContext context) {
    // Calculamos el techo de la gráfica (el valor más alto + un 15% de margen superior)
    final double maxY = [
      limitNeeds, spentNeeds,
      limitWants, spentWants,
      limitSavings, spentSavings
    ].reduce((curr, next) => curr > next ? curr : next) * 1.15;

    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Presupuesto vs. Gasto Real",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 25),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 100 : maxY, // Evita error si todos los valores son 0
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Fijos', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                          case 1: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Flexibles', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                          case 2: return const Padding(padding: EdgeInsets.only(top: 8), child: Text('Ahorro', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)));
                          default: return const Text('');
                        }
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const Text('');
                        return Text('Q${value.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey));
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                ),
                barGroups: [
                  _buildBarGroup(0, limitNeeds, spentNeeds, const Color(0xFF4A47F6)), // Azul para Fijos
                  _buildBarGroup(1, limitWants, spentWants, Colors.orange),           // Naranja para Flexibles
                  _buildBarGroup(2, limitSavings, spentSavings, const Color(0xFF2E7D32)), // Verde para Ahorro
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),
          // Leyenda explicativa
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.grey[300]!, "Límite"),
              const SizedBox(width: 15),
              _buildLegendItem(const Color(0xFF4A47F6), "Sano"),
              const SizedBox(width: 15),
              _buildLegendItem(Colors.redAccent, "Excedido"),
            ],
          )
        ],
      ),
    );
  }

  // Generador de las barras pareadas (Presupuesto vs Real)
  BarChartGroupData _buildBarGroup(int x, double limit, double spent, Color healthyColor) {
    // AQUÍ ESTÁ LA MAGIA: Si el gasto supera el límite, la barra se vuelve roja.
    final bool isOverBudget = spent > limit;

    return BarChartGroupData(
      x: x,
      barsSpace: 4, // Espacio entre las dos barras de la misma categoría
      barRods: [
        // 1. Barra del Límite (Presupuesto Planeado)
        BarChartRodData(
          toY: limit,
          color: Colors.grey[300],
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
        // 2. Barra del Gasto Real
        BarChartRodData(
          toY: spent,
          color: isOverBudget ? Colors.redAccent : healthyColor,
          width: 14,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
      ],
    );
  }
}