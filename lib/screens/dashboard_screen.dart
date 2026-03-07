import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart'; // NUEVO: Para formato de miles
import 'profile_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  // Variables de Estado para la Búsqueda y Filtro
  String _searchQuery = '';
  String _selectedFilterCategory = 'Todas';

  // Categorías combinadas para el filtro
  final List<String> _filterCategories = ['Todas', 'Comida', 'Transporte', 'Servicios', 'Ocio', 'Salud', 'Salario', 'Negocio', 'Inversión'];

  // Formateador de moneda (1,000.00)
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  Widget build(BuildContext context) {
    final Color purpleColor = const Color(0xFF4A47F6);
    final Color greenColor = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. CABECERA
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, Alex', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        Text('Tu panorama financiero hoy', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
                      child: const CircleAvatar(radius: 24, backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11')),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 2. PANELES DIVIDIDOS (CON FORMATO DE MILES)
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (!snapshot.hasData || !snapshot.data!.exists) return const Text('Sin datos del usuario');

                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      double safeBalance = (data['safe_balance'] ?? 0).toDouble();
                      double netWorth = (data['net_worth'] ?? 0).toDouble();

                      Color dynamicBalanceColor = safeBalance >= 0 ? const Color(0xFF2E7D32) : Colors.redAccent;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.2)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: dynamicBalanceColor, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(children: [const Icon(Icons.shield_outlined, color: Colors.white, size: 16), const SizedBox(width: 8), const Expanded(child: Text('SEGURO PARA GASTAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)))]),
                                    const SizedBox(height: 8),
                                    // FORMATO APLICADO AQUÍ
                                    Text('Q${currencyFormat.format(safeBalance)}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    const Text('Libre tras facturas', style: TextStyle(color: Colors.white70, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [Icon(Icons.account_balance_wallet_outlined, color: Colors.grey[600], size: 16), const SizedBox(width: 8), Expanded(child: Text('PATRIMONIO NETO', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)))]),
                                  const SizedBox(height: 8),
                                  // FORMATO APLICADO AQUÍ
                                  Text('Q${currencyFormat.format(netWorth)}', style: TextStyle(color: Colors.blueGrey[900], fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                    child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.cloud_done_outlined, color: greenColor, size: 12), const SizedBox(width: 4), Text('En vivo', style: TextStyle(color: greenColor, fontSize: 10, fontWeight: FontWeight.bold))]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                ),
                const SizedBox(height: 25),

                // 3 Y 4. GRÁFICA, BUSCADOR Y LISTA
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').collection('transactions').orderBy('date', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(40.0), child: CircularProgressIndicator()));

                    List<QueryDocumentSnapshot> docs = snapshot.hasData ? snapshot.data!.docs : [];
                    double totalIncome = 0.0;
                    double totalExpense = 0.0;

                    // Calculamos totales globales para la gráfica
                    for (var doc in docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      double amount = (data['amount'] ?? 0).toDouble();
                      if (data['is_expense'] ?? true) totalExpense += amount; else totalIncome += amount;
                    }
                    double maxY = (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2;
                    if (maxY == 0) maxY = 1000;

                    // APLICAMOS FILTROS SOLO PARA LA LISTA DE ACTIVIDAD
                    List<QueryDocumentSnapshot> filteredDocs = docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      String title = (data['title'] ?? '').toString().toLowerCase();
                      String category = data['category'] ?? '';

                      bool matchesSearch = _searchQuery.isEmpty || title.contains(_searchQuery);
                      bool matchesCategory = _selectedFilterCategory == 'Todas' || category == _selectedFilterCategory;

                      return matchesSearch && matchesCategory;
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- GRÁFICA ---
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withValues(alpha: 0.2))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Flujo de Caja del Mes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 180,
                                child: BarChart(
                                  BarChartData(
                                    alignment: BarChartAlignment.spaceAround, maxY: maxY, barTouchData: BarTouchData(enabled: false),
                                    titlesData: FlTitlesData(
                                      show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) => Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(value.toInt() == 0 ? 'Ingresos' : 'Gastos', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[700]))))),
                                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                                    barGroups: [
                                      BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalIncome, color: greenColor, width: 35, borderRadius: BorderRadius.circular(6))]),
                                      BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalExpense, color: Colors.amber, width: 35, borderRadius: BorderRadius.circular(6))]),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                // FORMATO APLICADO AQUÍ
                                children: [
                                  Text('Ingresos: Q${currencyFormat.format(totalIncome)}', style: TextStyle(color: greenColor, fontSize: 13, fontWeight: FontWeight.bold)),
                                  Text('Gastos: Q${currencyFormat.format(totalExpense)}', style: TextStyle(color: Colors.amber[700], fontSize: 13, fontWeight: FontWeight.bold)),
                                ],
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 25),

                        // --- ACTIVIDAD Y BUSCADOR ---
                        Text('Actividad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        const SizedBox(height: 15),

                        // BARRA DE BÚSQUEDA Y FILTROS
                        Row(
                          children: [
                            // Buscador
                            Expanded(
                              flex: 3,
                              child: TextField(
                                onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                                decoration: InputDecoration(
                                  hintText: 'Buscar...',
                                  prefixIcon: const Icon(Icons.search, size: 20),
                                  filled: true, fillColor: Colors.grey[100],
                                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Dropdown Categorías
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _selectedFilterCategory,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                    items: _filterCategories.map((String cat) => DropdownMenuItem<String>(value: cat, child: Text(cat, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis))).toList(),
                                    onChanged: (newValue) {
                                      if (newValue != null) setState(() => _selectedFilterCategory = newValue);
                                    },
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            // Botón Administrar
                            Container(
                              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                              child: IconButton(
                                icon: const Icon(Icons.tune, color: Colors.blueGrey),
                                onPressed: () {
                                  // Lógica futura para el Modal de Administrar Categorías
                                  debugPrint("Abrir modal de administrar categorías");
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // --- LISTA DE TRANSACCIONES FILTRADA ---
                        if (filteredDocs.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: Column(
                                children: [
                                  Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
                                  const SizedBox(height: 10),
                                  Text("No se encontraron transacciones", style: TextStyle(color: Colors.grey[500])),
                                ],
                              ),
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              var doc = filteredDocs[index];
                              var data = doc.data() as Map<String, dynamic>;

                              String title = data['title'] ?? 'Sin título';
                              String category = data['category'] ?? 'General';
                              double amount = (data['amount'] ?? 0).toDouble();
                              bool isExpense = data['is_expense'] ?? true;

                              // FORMATO APLICADO A LA LISTA DE ACTIVIDAD
                              String prefix = isExpense ? '-Q' : '+Q';
                              String amountStr = '$prefix${currencyFormat.format(amount)}';

                              IconData iconData = isExpense ? Icons.arrow_outward_rounded : Icons.call_received_rounded;
                              Color iconColor = isExpense ? Colors.redAccent : greenColor;

                              return _buildTransactionItem(
                                docId: doc.id,
                                title: title,
                                subtitle: category,
                                amount: amountStr,
                                icon: iconData,
                                iconColor: iconColor,
                                isExpense: isExpense,
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

  Widget _buildTransactionItem({
    required String docId, required String title, required String subtitle,
    required String amount, required IconData icon, required Color iconColor, required bool isExpense,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white, elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withValues(alpha: 0.1))),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isExpense ? Colors.blueGrey[900] : const Color(0xFF2E7D32), fontSize: 16)),
        onTap: () => debugPrint("Tocaste: $docId"),
      ),
    );
  }
}