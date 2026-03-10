import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../profile/profile_screen.dart';
import '../transactions/manage_categories_screen.dart';
import '../transactions/add_transaction_screen.dart';
import '../budget_and_goals/budget_screen.dart';

class MainDashboardScreen extends StatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  State<MainDashboardScreen> createState() => _MainDashboardScreenState();
}

class _MainDashboardScreenState extends State<MainDashboardScreen> {
  String _searchQuery = '';
  String _selectedFilterCategory = 'Todas';
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');

  // 1. AGREGA ESTA LÍNEA (El cerebro de la barra de búsqueda)
  final TextEditingController _searchController = TextEditingController();

  //2. AGREGA ESTE BLOQUE para limpiar la memoria cuando cierres la app
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Función para eliminar transacciones y devolver el saldo al usuario
  Future<void> _deleteTransaction(String docId, double amount, bool isExpense) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');
    final transactionRef = userRef.collection('transactions').doc(docId);

    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        double currentSafeBalance = (userSnapshot.data() as Map<String, dynamic>)['safe_balance'] ?? 0.0;

        // Revertimos el efecto del monto en el saldo
        double newSafeBalance = isExpense ? (currentSafeBalance + amount) : (currentSafeBalance - amount);

        transaction.delete(transactionRef);
        transaction.update(userRef, {'safe_balance': newSafeBalance});
      });
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    }
  }

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
                      child: CircleAvatar(radius: 24,backgroundColor: Colors.grey[200], child: Icon(Icons.person, color: Colors.grey[600], size: 30,),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 2. PANELES DE SALDO
                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData || !snapshot.data!.exists) return const SizedBox();
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      double safeBalance = (data['safe_balance'] ?? 0).toDouble();
                      double netWorth = (data['net_worth'] ?? 0).toDouble();

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(color: safeBalance >= 0 ? greenColor : Colors.redAccent, borderRadius: BorderRadius.circular(16)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('SEGURO PARA GASTAR', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    Text('Q${currencyFormat.format(safeBalance)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                                  Text('Q${currencyFormat.format(netWorth)}', style: TextStyle(color: Colors.blueGrey[900], fontSize: 18, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                ),
                
                const SizedBox(height: 25),

                // 3. SECCIÓN DE GRÁFICA Y ACTIVIDAD (TODO EN UN STREAM)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').collection('transactions').orderBy('date', descending: true).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                    List<QueryDocumentSnapshot> docs = snapshot.data?.docs ?? [];
                    double totalIncome = 0;
                    double totalExpense = 0;
                    List<String> dynamicCategories = ['Todas'];

                    for (var doc in docs) {
                      var data = doc.data() as Map<String, dynamic>;
                      double amt = (data['amount'] ?? 0).toDouble();
                      if (data['is_expense'] ?? true) totalExpense += amt; else totalIncome += amt;

                      String cat = data['category'] ?? '';
                      if (cat.isNotEmpty && !dynamicCategories.contains(cat)) dynamicCategories.add(cat);
                    }

                    // Filtrado de la lista
                    var filteredDocs = docs.where((doc) {
                      var data = doc.data() as Map<String, dynamic>;
                      bool matchesSearch = (data['title'] ?? '').toString().toLowerCase().contains(_searchQuery);
                      bool matchesCat = _selectedFilterCategory == 'Todas' || data['category'] == _selectedFilterCategory;
                      return matchesSearch && matchesCat;
                    }).toList();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gráfica
                        Container(
                          height: 200,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
                          child: BarChart(BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: (totalIncome > totalExpense ? totalIncome : totalExpense) * 1.2 + 100,
                            barGroups: [
                              BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: totalIncome, color: greenColor, width: 30)]),
                              BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: totalExpense, color: Colors.orange, width: 30)]),
                            ],
                            titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v == 0 ? 'In' : 'Out')))),
                            gridData: const FlGridData(show: false), borderData: FlBorderData(show: false),
                          )),
                        ),
                        const SizedBox(height: 25),

                        Text('Actividad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        const SizedBox(height: 15),

                        // BARRA DE BÚSQUEDA Y FILTRO DE CATEGORÍAS
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: TextField(
                                controller: _searchController, // <- AGREGA ESTA LÍNEA AQUÍ
                                onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                                decoration: InputDecoration(
                                    hintText: 'Buscar...',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
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
                                    value: dynamicCategories.contains(_selectedFilterCategory) ? _selectedFilterCategory : 'Todas',
                                    isExpanded: true,
                                    items: dynamicCategories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 12)))).toList(),
                                    onChanged: (v) => setState(() => _selectedFilterCategory = v!),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.tune),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen())),
                            )
                          ],
                        ),
                        const SizedBox(height: 15),

                        // LISTA DE TRANSACCIONES CON SLIDE
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredDocs.length,
                          itemBuilder: (context, index) {
                            var doc = filteredDocs[index];
                            var data = doc.data() as Map<String, dynamic>;
                            double amt = (data['amount'] ?? 0).toDouble();
                            bool isExp = data['is_expense'] ?? true;
                            String dateStr = data['date'] != null ? DateFormat('dd/MM').format((data['date'] as Timestamp).toDate()) : '';

                            return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Slidable(
                                  key: ValueKey(doc.id), // Clave única necesaria para que Slidable funcione
                                  // Panel que aparece al deslizar hacia la DERECHA (Editar)
                                  startActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (context) => AddTransactionScreen(editDocId: doc.id, editData: data),
                                          );
                                        },
                                        backgroundColor: Colors.blueAccent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.edit,
                                        label: 'Editar',
                                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
                                      ),
                                    ],
                                  ),
                                  // Panel que aparece al deslizar hacia la IZQUIERDA (Borrar)
                                  endActionPane: ActionPane(
                                    motion: const DrawerMotion(),
                                    children: [
                                      SlidableAction(
                                        onPressed: (_) => _deleteTransaction(doc.id, amt, isExp),
                                        backgroundColor: Colors.redAccent,
                                        foregroundColor: Colors.white,
                                        icon: Icons.delete,
                                        label: 'Borrar',
                                        borderRadius: const BorderRadius.only(topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
                                      ),
                                    ],
                                  ),
                                  child: _buildTransactionItem(
                                    title: data['title'] ?? '',
                                    subtitle: "${data['category']} • $dateStr",
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

  Widget _buildTransactionItem({required String title, required String subtitle, required String amount, required IconData icon, required Color iconColor, required bool isExpense}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: iconColor.withOpacity(0.1), child: Icon(icon, color: iconColor, size: 18)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Text(amount, style: TextStyle(fontWeight: FontWeight.bold, color: isExpense ? Colors.black : Colors.green[700])),
      ),
    );
  }
}