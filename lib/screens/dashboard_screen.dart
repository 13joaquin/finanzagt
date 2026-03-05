import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
                    GestureDetector(
                      onTap: (){
                        //Navega hacia la pantalla de perfil con una animacion por defecto
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()),
                        );
                      },
                      child: const CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                            'https://i.pravatar.cc/150?img=11'), // Imagen de prueba
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),

                // 2. Paneles Divididos: Saldo Seguro vs Patrimonio Neto
                FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc('test_user_123').get(),
                    builder: (context, snapshot) {
                      // 1. Estado de carga
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                          height: 150,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                          ),
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      }

                      // 2. Estado de error
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                      }

                      // 3. Estado sin datos (o documento no existe)
                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Text('Crea el usuario "test_user_123" en Firebase para ver los datos.', style: TextStyle(color: Colors.grey));
                      }

                      // 4. ¡DATOS RECIBIDOS! Los extraemos
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      double safeBalance = (data['safe_balance'] ?? 0).toDouble();
                      double netWorth = (data['net_worth'] ?? 0).toDouble();

                      // LÓGICA DE COLOR CONDICIONAL: Verde si es >= 0, Rojo si es negativo
                      Color dynamicBalanceColor = safeBalance >= 0 ? const Color(0xFF2E7D32) : Colors.redAccent;

                      // 5. Retornamos tu diseño visual, pero con variables reales
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.2)), // Corregido: alpha 0.2
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            //Panel Dinamico (Seguro para gastar)
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: dynamicBalanceColor, // APLICAMOS EL COLOR DINÁMICO AQUÍ
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
                                    // AQUÍ PONEMOS EL DATO REAL DE FIREBASE (Saldo Seguro)
                                    Text('Q${safeBalance.toStringAsFixed(2)}', style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 4),
                                    const Text('Libre tras facturas y ahorro',
                                        style: TextStyle(
                                            color: Colors.white70, fontSize: 10)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 15), // Corregido: width en lugar de height
                            //Panel Blanco (Patrimonio Neto)
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance_wallet_outlined,
                                          color: Colors.grey[600], size: 16),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text('PATRIMONIO NETO',
                                          style: TextStyle(color: Colors.grey[600],
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold))),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // AQUÍ PONEMOS EL DATO REAL DE FIREBASE (Patrimonio Neto)
                                  Text('Q${netWorth.toStringAsFixed(2)}', style: TextStyle(
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
                                        Icon(Icons.cloud_done_outlined, color: greenColor, size: 12),
                                        const SizedBox(width: 4),
                                        Text('En vivo', style: TextStyle(
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
                      );
                    }
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

                // StreamBuilder mantiene una conexion en vivo con la subcolección 'transactions'
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc('test_user_123') // CORREGIDO: Guion bajo en lugar de dos puntos
                      .collection('trnsactions')
                      .orderBy('date', descending: true) // Ordena de más reciente a mas antigua
                      .snapshots(),
                  builder: (context, snapshot){
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    if(snapshot.hasError){
                      return const Center(child: Text('Error al cargar transacciones'));
                    }
                    if(!snapshot.hasData || snapshot.data!.docs.isEmpty){
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40.0),
                          child: Column(
                            children: [
                              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text("No hay transacciones recientes", style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        ),
                      );
                    }
                    // Si hay datos, contruimos la lista dinamica
                    return ListView.builder(
                      shrinkWrap: true, // Importante para usar ListView dentro de un SingleChildScrollView
                      physics: const NeverScrollableScrollPhysics(), // Evita scroll doble
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index){
                        var doc = snapshot.data!.docs[index];
                        var data = doc.data() as Map<String, dynamic>;

                        // Extracción segura de datos
                        String title = data['title'] ?? 'Sin título';
                        String category = data['category'] ?? 'General';
                        double amount = (data['amount'] ?? 0).toDouble();
                        bool isExpense = data['is_expense'] ?? true;

                        // Formateamos la cantidad a Quetzales
                        String prefix = isExpense ? '-Q' : '+Q';
                        String amountStr = '$prefix${amount.toStringAsFixed(2)}';

                        // Seleccionamos un ícono básico según si es ingreso o gasto
                        IconData iconData = isExpense ? Icons.arrow_outward_rounded : Icons.call_received_rounded;
                        Color iconColor = isExpense ? Colors.redAccent : const Color(0xFF2E7D32);

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
                    );
                  },
                ),
                const SizedBox(height: 80),
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
// Widget para la transacción individual (Preparado para Firebase)
Widget _buildTransactionItem({
  required String docId,
  required String title,
  required String subtitle,
  required String amount,
  required IconData icon,
  required Color iconColor,
  required bool isExpense,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    color: Colors.white,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      trailing: Text(
        amount,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isExpense ? Colors.blueGrey[900] : const Color(0xFF2E7D32),
          fontSize: 16,
        ),
      ),
      onTap: () {
        // Lógica futura: Abrir detalle de la transacción
        debugPrint("Tocaste la transacción con ID: $docId");
      },
    ),
  );
}