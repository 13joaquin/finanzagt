import 'package:flutter/material.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  // Datos simulados (luego los conectaremos a Firebase)
  final double totalSaved = 4500.00;

  @override
  Widget build(BuildContext context) {
    final Color greenColor = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Ahorro y Metas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARJETA DE AHORRO TOTAL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: greenColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: greenColor.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 5))],
              ),
              child: Column(
                children: [
                  const Text('AHORRO TOTAL', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('Q${totalSaved.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shield_outlined, color: Colors.white, size: 16),
                        SizedBox(width: 5),
                        Text('Protege tu Patrimonio Neto', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // SECCIÓN MIS OBJETIVOS Y BOTÓN AGREGAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mis Objetivos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                TextButton.icon(
                  onPressed: () {
                    // Aquí abriremos el modal para crear una nueva meta
                  },
                  icon: Icon(Icons.add_circle, color: greenColor),
                  label: Text('Agregar nuevo', style: TextStyle(color: greenColor, fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 15),

            // LISTA DE AHORROS CREADOS
            _buildGoalCard(title: 'Fondo de Emergencia', icon: Icons.medical_services_outlined, saved: 3000, target: 10000, color: Colors.blue),
            const SizedBox(height: 15),
            _buildGoalCard(title: 'Viaje a la Playa', icon: Icons.beach_access_outlined, saved: 1500, target: 3000, color: Colors.orange),
          ],
        ),
      ),
    );
  }

  // Widget de cada meta
  Widget _buildGoalCard({required String title, required IconData icon, required double saved, required double target, required Color color}) {
    double progress = saved / target;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Meta: Q${target.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              // Botón para inyectarle dinero a la meta
              IconButton(
                onPressed: () {}, // Lógica para transferir desde el saldo principal
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(backgroundColor: Colors.grey[100]),
              )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Q${saved.toStringAsFixed(0)}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8, borderRadius: BorderRadius.circular(10)),
        ],
      ),
    );
  }
}