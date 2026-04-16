import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

// Importamos las pantallas
import 'goals/savings_goals_screen.dart';
import 'goals/fixed_expenses_screen.dart';
import 'goals/flexible_expenses_screen.dart';
import 'budget_config_screen.dart';
import 'package:finanzagt/data/models/debt_model.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    // Obtenemos el usuario real de Firebase
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Presupuesto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // BOTÓN DE CONFIGURACIÓN (Engranaje)
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BudgetConfigScreen()),
              );
            },
          )
        ],
      ),
      // PRIMER STREAM: Escucha los datos principales del usuario (Los límites 50/30/20)
      body: StreamBuilder<DocumentSnapshot>(
          stream: userRef.snapshots(),
          builder: (context, userSnap) {
            if (userSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            // Variables para guardar los límites. Si no existen, inician en 0.
            double limitNeeds = 0.0;
            double limitWants = 0.0;
            double limitSavings = 0.0;

            if (userSnap.hasData && userSnap.data!.exists) {
              final userData = userSnap.data!.data() as Map<String, dynamic>?;
              if (userData != null) {
                limitNeeds = (userData['limit_needs'] ?? 0).toDouble();
                limitWants = (userData['limit_wants'] ?? 0).toDouble();
                limitSavings = (userData['limit_savings'] ?? 0).toDouble();
              }
            }

            // SEGUNDO Y TERCER STREAM: Escuchan los gastos reales para llenar la barra
            return StreamBuilder<QuerySnapshot>(
                stream: userRef.collection('fixed_expenses').snapshots(),
                builder: (context, fixedSnap) {
                  return StreamBuilder<QuerySnapshot>(
                      stream: userRef.collection('transactions').where('category', isEqualTo: 'Ocio/Flexible').snapshots(),
                      builder: (context, flexibleSnap) {

                        // LÓGICA DE CÁLCULOS
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

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              // MENSAJE AMIGABLE SI AÚN NO CONFIGURA SU SUELDO
                              if (limitNeeds == 0)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, color: Colors.blue),
                                      const SizedBox(width: 15),
                                      Expanded(
                                        child: Text(
                                          "Toca el ícono de ⚙️ arriba a la derecha para configurar tu ingreso y activar tus límites.",
                                          style: TextStyle(color: Colors.blue[800]),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // --- TARJETA: GASTOS FIJOS ---
                              _buildBudgetCard(
                                title: 'Gastos Fijos',
                                subtitle: 'Necesidades (50%)',
                                spent: totalFixed,
                                total: limitNeeds, // <- Límite dinámico desde Firebase
                                icon: Icons.home_work_outlined,
                                color: const Color(0xFF4A47F6),
                                actionLabel: 'Ver detalles',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FixedExpensesScreen())),
                              ),
                              const SizedBox(height: 20),

                              // --- TARJETA: GASTOS FLEXIBLES ---
                              _buildBudgetCard(
                                title: 'Gastos Flexibles',
                                subtitle: 'Deseos y Ocio (30%)',
                                spent: spentFlexible,
                                total: limitWants, // <- Límite dinámico desde Firebase
                                icon: Icons.shopping_bag_outlined,
                                color: Colors.orange,
                                actionLabel: 'Anotar gasto',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const FlexibleExpensesScreen())),
                              ),
                              const SizedBox(height: 20),

                              // --- TARJETA: SANTUARIO (AHORRO) ---
                              _buildBudgetCard(
                                title: 'Santuario',
                                subtitle: 'Ahorros y Metas (20%)',
                                spent: 0, // En el futuro sumaremos las metas aquí
                                total: limitSavings, // <- Límite dinámico desde Firebase
                                icon: Icons.savings_outlined,
                                color: const Color(0xFF2E7D32),
                                actionLabel: 'Mis metas',
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen())),
                              ),
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

  // --- WIDGET DE LA TARJETA (Actualizado con seguridad matemática) ---
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
    // Evitamos el error de división por cero si el usuario aún no pone su sueldo
    double safeTotal = total > 0 ? total : 1;
    double progress = (spent / safeTotal).clamp(0.0, 1.0);

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