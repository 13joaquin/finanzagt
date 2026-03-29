import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';

// Importamos tus Providers
import '../../providers/user_provider.dart';
import '../../providers/transaction_provider.dart';

// Importamos pantallas adicionales
import '../profile/profile_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  String _searchQuery = '';
  String _selectedFilterCategory = 'Todas';
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // TODO: Mover esta lógica al TransactionRepository en el siguiente paso
  Future<void> _deleteTransaction(String docId, double amount, bool isExpense) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');
    final transactionRef = userRef.collection('transactions').doc(docId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        double currentSafeBalance = (userSnapshot.data() as Map<String, dynamic>)['safe_balance'] ?? 0.0;
        double currentNetWorth = (userSnapshot.data() as Map<String, dynamic>)['net_worth'] ?? 0.0;

        double newSafeBalance = isExpense ? (currentSafeBalance + amount) : (currentSafeBalance - amount);
        double newNetWorth = isExpense ? (currentNetWorth + amount) : (currentNetWorth - amount);

        transaction.delete(transactionRef);
        transaction.update(userRef, {
          'safe_balance': newSafeBalance,
          'net_worth': newNetWorth
        });
      });
    } catch (e) {
      debugPrint("Error al eliminar transacción: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color greenColor = const Color(0xFF2E7D32);

    // 1. Obtenemos los datos del Usuario desde el UserProvider
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
                // --- CABECERA ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, ${currentUser.displayName}',
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

                // --- PANELES DE SALDO (Datos desde UserProvider) ---
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                              color: currentUser.safeToSpend >= 0 ? greenColor : Colors.redAccent,
                              borderRadius: BorderRadius.circular(16)
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SEGURO PARA GASTAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              Text('Q${currencyFormat.format(currentUser.safeToSpend)}',
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
                            Text('PATRIMONIO NETO', style: TextStyle(color: Colors.grey[600], fontSize: 10, fontWeight: FontWeight.bold)),
                            Text('Q${currencyFormat.format(currentUser.netWorth)}',
                                style: TextStyle(color: Colors.blueGrey[900], fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // --- SECCIÓN DE TRANSACCIONES (Datos desde TransactionProvider) ---
                Consumer<TransactionProvider>(
                  builder: (context, txProvider, child) {
                    if (txProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    // Filtramos la lista según la búsqueda del usuario
                    final filteredDocs = txProvider.transactions.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final title = (data['title'] ?? '').toString().toLowerCase();
                      final category = data['category'] ?? '';

                      final matchesSearch = title.contains(_searchQuery);
                      final matchesCat = _selectedFilterCategory == 'Todas' || category == _selectedFilterCategory;

                      return matchesSearch && matchesCat;
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gráfica de Barras (Usando totales del Provider)
                        _buildChart(txProvider.totalIncome, txProvider.totalExpense, greenColor),

                        const SizedBox(height: 25),
                        Text('Actividad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        const SizedBox(height: 15),

                        // Barra de Filtros
                        _buildFilterBar(txProvider.categories),

                        const SizedBox(height: 15),

                        // Lista de Actividad
                        if (filteredDocs.isEmpty)
                          const Center(child: Padding(padding: EdgeInsets.all(40), child: Text("No hay movimientos", style: TextStyle(color: Colors.grey))))
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              final doc = filteredDocs[index];
                              final data = doc.data() as Map<String, dynamic>;
                              final amt = (data['amount'] ?? 0).toDouble();
                              final isExp = data['is_expense'] ?? true;
                              final date = data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now();

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Slidable(
                                  key: ValueKey(doc.id),
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) => _deleteTransaction(doc.id, amt, isExp),
                                        backgroundColor: Colors.redAccent,
                                        icon: Icons.delete,
                                        label: 'Borrar',
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                    ],
                                  ),
                                  child: _buildTransactionItem(
                                    title: data['title'] ?? 'Sin título',
                                    subtitle: "${data['category']} • ${DateFormat('dd/MM').format(date)}",
                                    amount: "${isExp ? '-' : '+'}Q${currencyFormat.format(amt)}",
                                    icon: isExp ? Icons.arrow_outward_rounded : Icons.call_received_rounded,
                                    iconColor: isExp ? Colors.redAccent : greenColor,
                                    isExpense: isExp,
                                  ),
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

  // --- WIDGETS DE APOYO (Para mantener el build() limpio) ---

  Widget _buildChart(double income, double expense, Color green) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: BarChart(BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: (income > expense ? income : expense) * 1.2 + 100,
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

  Widget _buildFilterBar(List<String> categories) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            decoration: InputDecoration(hintText: 'Buscar...', prefixIcon: const Icon(Icons.search), filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: categories.contains(_selectedFilterCategory) ? _selectedFilterCategory : 'Todas',
                isExpanded: true,
                items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                onChanged: (v) => setState(() => _selectedFilterCategory = v ?? 'Todas'),
              ),
            ),
          ),
        ),
      ],
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