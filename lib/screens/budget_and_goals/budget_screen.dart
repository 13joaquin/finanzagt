import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
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
    // 1. Obtenemos el usuario real de Firebase
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Referencia dinámica a Firestore usando el UID real
    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Presupuesto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: userRef.collection('fixed_expenses').snapshots(),
          builder: (context, fixedSnap) {
            return StreamBuilder<QuerySnapshot>(
                stream: userRef.collection('transactions')
                    .where('category', isEqualTo: 'Ocio/Flexible').snapshots(),
                builder: (context, flexibleSnap) {

                  // LOGICA DE CALCULOS
                  double totalFixed = 0;
                  if (fixedSnap.hasData) {
                    for (var doc in fixedSnap.data!.docs) {
                      totalFixed += (doc['amount'] ?? 0).toDouble();
                    }
                  }

                  double spentFlexible = 0;
                  if (flexibleSnap.hasData) {
                    for (var doc in flexibleSnap.data!.docs) {
                      spentFlexible += (doc['amount'] ?? 0).toDouble();
                    }
                  }

                  // 3. RETORNAMOS TU DISEÑO ORIGINAL RE-CONECTADO
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // --- TARJETA: GASTOS FIJOS ---
                        _buildBudgetCard(
                          title: 'Gastos Fijos',
                          subtitle: 'Vivienda, suscripciones, etc.',
                          spent: totalFixed,
                          total: 3500, // Luego haremos que este valor sea editable en Fase 2
                          icon: Icons.home_work_outlined,
                          color: const Color(0xFF4A47F6),
                          actionLabel: 'Ver detalles',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FixedExpensesScreen())
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- TARJETA: GASTOS FLEXIBLES ---
                        _buildBudgetCard(
                          title: 'Gastos Flexibles',
                          subtitle: 'Comida, salidas, gustos.',
                          spent: spentFlexible,
                          total: 1500, // Luego haremos que este valor sea editable en Fase 2
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.orange,
                          actionLabel: 'Anotar gasto',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const FlexibleExpensesScreen())
                          ),
                        ),
                        const SizedBox(height: 20),

                        // --- TARJETA: SANTUARIO (AHORRO) ---
                        _buildBudgetCard(
                          title: 'Santuario',
                          subtitle: 'Tus metas de ahorro.',
                          spent: 450, // Este valor vendrá de tus metas en el futuro
                          total: 1000,
                          icon: Icons.savings_outlined,
                          color: const Color(0xFF2E7D32),
                          actionLabel: 'Mis metas',
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SavingsGoalsScreen())
                          ),
                        ),
                      ],
                    ),
                  );
                }
            );
          }
      ),
    );
  }

  // --- TU WIDGET DE DISEÑO ORIGINAL ---
  Widget _buildBudgetCard({
    required String title,
    required String subtitle,
    required double spent,
    required double total,
    required IconData icon,
    required Color color,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    double progress = (spent / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: color.withOpacity(0.1), child: Icon(icon, color: color)),
              const SizedBox(width: 15),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600]))
                      ]
                  )
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Q${spent.toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                Text('de Q${total.toStringAsFixed(2)}', style: TextStyle(color: Colors.grey[600]))
              ]
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(10)
          ),
          const SizedBox(height: 15),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: onTap, child: Text(actionLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold)))
          ),
        ],
      ),
    );
  }
}