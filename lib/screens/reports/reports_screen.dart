import 'package:flutter/material.dart';
// Nota: Usaremos contenedores y formas para representar las gráficas
// antes de importar librerías pesadas como fl_chart.

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Informes", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {}, // Selector de mes/año
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. RESUMEN DE SALUD FINANCIERA
            _buildHealthScoreCard(),

            const SizedBox(height: 25),
            const Text("Distribución de Gastos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 2. GRÁFICA DE PASTEL (CATEGORÍAS)
            _buildCategoryPieChartPlaceholder(),

            const SizedBox(height: 25),
            const Text("Tendencia Mensual",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 3. GRÁFICA DE BARRAS (INGRESOS VS GASTOS)
            _buildMonthlyBarChartPlaceholder(),

            const SizedBox(height: 25),
            const Text("Top Categorías",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // 4. EL EXTRA: LISTA DE MAYORES GASTOS (Insights)
            _buildTopExpensesList(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DE UX (VISUALES) ---

  Widget _buildHealthScoreCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A47F6), Color(0xFF7673FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Salud Financiera", style: TextStyle(color: Colors.white70, fontSize: 14)),
                SizedBox(height: 5),
                Text("¡Excelente!", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 5),
                Text("Has ahorrado el 15% de tus ingresos este mes.", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60, height: 60,
                child: CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 8,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.greenAccent),
                ),
              ),
              const Text("85", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildCategoryPieChartPlaceholder() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          // Simulación de Pie Chart
          const Expanded(
            flex: 1,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.orange,
              child: CircleAvatar(radius: 40, backgroundColor: Colors.white),
            ),
          ),
          const SizedBox(width: 20),
          // Leyenda
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _legendItem(Colors.orange, "Comida", "45%"),
                _legendItem(Colors.blue, "Renta", "30%"),
                _legendItem(Colors.purple, "Ocio", "25%"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMonthlyBarChartPlaceholder() {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _barItem("Ene", 0.6, 0.4),
          _barItem("Feb", 0.8, 0.5),
          _barItem("Mar", 0.7, 0.9), // Mes crítico
          _barItem("Abr", 0.9, 0.3), // Mes bueno
        ],
      ),
    );
  }

  Widget _buildTopExpensesList() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          _expenseTile(Icons.fastfood_outlined, "Alimentación", "Q 2,450", Colors.orange),
          const Divider(height: 1),
          _expenseTile(Icons.directions_car_outlined, "Transporte", "Q 800", Colors.blue),
          const Divider(height: 1),
          _expenseTile(Icons.movie_outlined, "Entretenimiento", "Q 400", Colors.purple),
        ],
      ),
    );
  }

  // --- COMPONENTES ATÓMICOS ---

  Widget _legendItem(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _barItem(String label, double h1, double h2) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 8, height: 100 * h1, color: Colors.green),
            const SizedBox(width: 4),
            Container(width: 8, height: 100 * h2, color: Colors.redAccent),
          ],
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _expenseTile(IconData icon, String title, String amount, Color color) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color, size: 20)),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      trailing: Text(amount, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
    );
  }
}