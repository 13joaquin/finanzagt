import 'package:flutter/material.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //Colores basados en tu captura
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
                // 1. Cabecera
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, Alex',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight
                              .bold, color: Colors.blueGrey[900]),
                        ),
                        Text(
                          'Tu panorama financiero hoy',
                          style: TextStyle(
                              fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?img=11'), // Imagen de prueba
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 2. Paneles Divididos: Saldo Seguro vs Patrimonio Neto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.green.withValues(alpha: 2)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      //Panel Morado (Seguro para gastar)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: purpleColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.shield_outlined,
                                      color: Colors.white, size: 16),
                                  const SizedBox(width: 8),
                                  const Expanded(child: Text(
                                      'SEGURO PARA GASTAR', style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text('Q 2124.51', style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              const Text('Libre tras faturas y ahorro',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      //Panel Blanco (Patrimonio Neto)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet_outlined,
                                    color: Colors.green[600], size: 16),
                                const SizedBox(width: 8),
                                Expanded(child: Text('PATRIMONIO NETO',
                                    style: TextStyle(color: Colors.grey[600],
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold))),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('Q45,200', style: TextStyle(
                                color: Colors.blueGrey[900],
                                fontSize: 22,
                                fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.arrow_outward, color: greenColor,
                                      size: 12),
                                  const SizedBox(width: 4),
                                  Text('+2.4% este mes', style: TextStyle(
                                      color: greenColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 3. Gráfica de Flujo de Caja 
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Flujo de Caja del Mess', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900])),
                      // Barras estáticas por ahora (Luego las cambiaremos por fl_chart si deseas gráficos avanzados)
                      _buildSimpleBar('Ingresos', greenColor, 0.8),
                      const SizedBox(height: 15),
                      _buildSimpleBar('Gastos', Colors.amber, 0.15),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Ingresos: Q2800', style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                          Text('Gastos: Q175.49', style: TextStyle(
                              color: Colors.grey[500], fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // 4. Sección de Actividad
                Text('Actividad', style: TextStyle(fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900])),
                const SizedBox(height: 15),

                //Aqui irian tus transaciones (ej: Mercadona, Spotify)
                Center(child: Text("Lista de transacciones aqui",
                    style: TextStyle(color: Colors.grey))),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleBar(String label, Color color, double percentage) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 14))),
        Expanded(
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: percentage,
              child: Container(
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
        ),
      ],
    );
  }
}