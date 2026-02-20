import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF0A4D68);
    final Color safeBalanceColor = const Color(0xFF2E7D32); // Verde para "Seguro"

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1 y 2. Cabecera: Saludo, Panorama y Foto de Perfil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hola, Joaquín',
                          style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: primaryColor),
                        ),
                        Text(
                          'Tu panorama financiero hoy',
                          style: GoogleFonts.inter(
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

                // 3. Paneles Divididos: Saldo Seguro vs Patrimonio Neto
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        title: 'Saldo seguro',
                        amount: 'Q 1,250.00', // Moneda GTQ
                        color: safeBalanceColor,
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildInfoCard(
                        title: 'Patrimonio neto',
                        amount: 'Q 14,300.00', // Moneda GTQ
                        color: primaryColor,
                        icon: Icons.account_balance_wallet_outlined,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 4. Gráfica de Flujo de Caja (Placeholder)
                Text(
                  'Flujo de caja del mes',
                  style: GoogleFonts.inter(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                  ),
                  child: Center(
                    child: Text(
                      '[ Aquí irá la gráfica de ingresos vs gastos ]\n(Sugerencia: usar paquete fl_chart)',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // 5 y 6. Controles del Panel y Lista de Transacciones
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transacciones',
                      style: GoogleFonts.inter(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    // Botón para administrar categorías (Modal)
                    TextButton.icon(
                      onPressed: () {
                        // Aquí abriremos el BottomSheet modal para categorías
                        debugPrint("Abrir modal de categorías");
                      },
                      icon: const Icon(Icons.category_outlined, size: 18),
                      label: Text(
                        'Categorías',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),

                // Barra de Búsqueda y Filtro Rápido
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar...',
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_list),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Lista de Transacciones (Simulada con Swipe-to-delete)
                _buildTransactionItem('Supermercado La Torre', 'Q -450.00', Icons.shopping_cart, Colors.orange),
                _buildTransactionItem('Pago de Nómina', 'Q +4,000.00', Icons.attach_money, Colors.green),
                _buildTransactionItem('Suscripción Netflix', 'Q -75.00', Icons.movie, Colors.purple),
                _buildTransactionItem('Gasolina', 'Q -200.00', Icons.local_gas_station, Colors.red),

                const SizedBox(height: 80), // Espacio para no chocar con el FAB
              ],
            ),
          ),
        ),
      ),
      // Mantenemos el botón flotante para registro rápido de emergencia
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget reutilizable para las tarjetas superiores
  Widget _buildInfoCard({required String title, required String amount, required Color color, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  // Widget para la transacción individual (Con funcionalidad de Deslizar)
  Widget _buildTransactionItem(String title, String amount, IconData icon, Color iconColor) {
    bool isIncome = amount.contains('+');

    // Dismissible permite el "Swipe" (Deslizar) estándar en móviles
    return Dismissible(
      key: UniqueKey(),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        color: Colors.blue, // Deslizar derecha para Editar
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red, // Deslizar izquierda para Eliminar
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          debugPrint("Eliminar $title");
        } else {
          debugPrint("Editar $title");
        }
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: ListTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor),
          ),
          title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          subtitle: Text(isIncome ? 'Ingreso' : 'Gasto', style: GoogleFonts.inter(fontSize: 12)),
          trailing: Text(
            amount,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green[700] : Colors.black87,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
