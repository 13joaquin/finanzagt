import 'package:flutter/material.dart';
import 'savings_goals_screen.dart'; // IMPORTACIÓN AGREGADA PARA SOLUCIONAR EL ERROR

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Presupuesto', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
        automaticallyImplyLeading: false, // Quita la flecha de regreso porque ahora es una pestaña principal
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBudgetCard(
                title: 'Gastos Fijos y Hogar',
                subtitle: 'Facturas, alquiler, servicios',
                icon: Icons.home_rounded,
                color: Colors.blue,
                spent: 2500,
                total: 3000,
                actionLabel: 'Ver Facturas',
                onTap: () {
                  // Futura conexión para Gastos Fijos
                }
            ),
            const SizedBox(height: 20),
            _buildBudgetCard(
                title: 'Flexibles y Ocio',
                subtitle: 'Comida fuera, compras, diversión',
                icon: Icons.local_cafe_rounded,
                color: Colors.orange,
                spent: 800,
                total: 1500,
                actionLabel: 'Ver Límite',
                onTap: () {
                  // Futura conexión para Flexibles
                }
            ),
            const SizedBox(height: 20),
            _buildBudgetCard(
                title: 'Ahorro y Metas',
                subtitle: 'Fondo de emergencia, inversiones',
                icon: Icons.trending_up_rounded,
                color: const Color(0xFF2E7D32),
                spent: 500,
                total: 1000,
                actionLabel: 'Mis Metas',
                onTap: () {
                  // NAVEGACIÓN CORRECTA EXCLUSIVA DE ESTA TARJETA
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()));
                }
            ),
            const SizedBox(height: 80), // Espacio para que el botón flotante no tape
          ],
        ),
      ),
    );
  }

  // Se agregó 'required VoidCallback onTap' para que cada tarjeta haga algo distinto
  Widget _buildBudgetCard({
    required String title, required String subtitle, required IconData icon,
    required Color color, required double spent, required double total,
    required String actionLabel, required VoidCallback onTap,
  }) {
    double progress = spent / total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
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
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Q${spent.toStringAsFixed(0)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text('de Q${total.toStringAsFixed(0)}', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap, // Llamamos a la función que le pasamos arriba
              child: Text(actionLabel, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}