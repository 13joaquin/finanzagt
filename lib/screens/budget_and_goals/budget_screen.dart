import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'goals/savings_goals_screen.dart';
import 'goals/fixed_expenses_screen.dart';
import 'goals/flexible_expenses_screen.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    final String userId = 'test_user_123';
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Presupuesto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white, foregroundColor: Colors.blueGrey[900], elevation: 0, automaticallyImplyLeading: false,
      ),
      // USAMOS STREAMBUILDERS PARA LEER DATOS EN VIVO
      body: StreamBuilder<QuerySnapshot>(
          stream: userRef.collection('fixed_expenses').snapshots(),
          builder: (context, fixedSnap) {
            return StreamBuilder<QuerySnapshot>(
                stream: userRef.collection('transactions').where('category', isEqualTo: 'Ocio/Flexible').snapshots(),
                builder: (context, flexibleSnap) {
                  return StreamBuilder<QuerySnapshot>(
                      stream: userRef.collection('goals').snapshots(),
                      builder: (context, goalsSnap) {

                        // 1. Calcular Gastos Fijos (Asumimos un límite de Q3000 por ahora)
                        double totalFixedLimit = 3000.0;
                        double fixedSpent = 0.0;
                        if (fixedSnap.hasData) {
                          for (var doc in fixedSnap.data!.docs) {
                            fixedSpent += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
                          }
                        }

                        // 2. Calcular Flexibles (Asumimos límite de Q1500)
                        double totalFlexLimit = 1500.0;
                        double flexSpent = 0.0;
                        if (flexibleSnap.hasData) {
                          for (var doc in flexibleSnap.data!.docs) {
                            flexSpent += ((doc.data() as Map<String, dynamic>)['amount'] ?? 0).toDouble();
                          }
                        }

                        // 3. Calcular Ahorros
                        double totalGoalLimit = 0.0;
                        double goalsSaved = 0.0;
                        if (goalsSnap.hasData) {
                          for (var doc in goalsSnap.data!.docs) {
                            var data = doc.data() as Map<String, dynamic>;
                            totalGoalLimit += (data['target_amount'] ?? 0).toDouble();
                            goalsSaved += (data['saved_amount'] ?? 0).toDouble();
                          }
                        }
                        if (totalGoalLimit == 0) totalGoalLimit = 1; // Evitar división por cero

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBudgetCard(
                                  title: 'Gastos Fijos y Hogar', subtitle: 'Facturas, alquiler, servicios', icon: Icons.home_rounded, color: Colors.blue,
                                  spent: fixedSpent, total: totalFixedLimit, actionLabel: 'Ver Facturas',
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FixedExpensesScreen()))
                              ),
                              const SizedBox(height: 20),
                              _buildBudgetCard(
                                  title: 'Flexibles y Ocio', subtitle: 'Comida fuera, compras, diversión', icon: Icons.local_cafe_rounded, color: Colors.orange,
                                  spent: flexSpent, total: totalFlexLimit, actionLabel: 'Ver Límite',
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlexibleExpensesScreen()))
                              ),
                              const SizedBox(height: 20),
                              _buildBudgetCard(
                                  title: 'Ahorro y Metas', subtitle: 'Fondo de emergencia, inversiones', icon: Icons.trending_up_rounded, color: const Color(0xFF2E7D32),
                                  spent: goalsSaved, total: totalGoalLimit, actionLabel: 'Mis Metas',
                                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()))
                              ),
                              const SizedBox(height: 80),
                            ],
                          ),
                        );
                      }
                  );
                }
            );
          }
      ),
    );
  }

  Widget _buildBudgetCard({required String title, required String subtitle, required IconData icon, required Color color, required double spent, required double total, required String actionLabel, required VoidCallback onTap}) {
    double progress = total > 0 ? (spent / total) : 0;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)), const SizedBox(width: 15),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]))])),
            ],
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Q${spent.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)), Text('de Q${total.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600]))]),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 15),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: onTap, child: Text(actionLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold))))
        ],
      ),
    );
  }
}