import 'package:flutter/material.dart';

class EmergencyFundEduScreen extends StatelessWidget {
  const EmergencyFundEduScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lección 1', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.security_rounded, color: Colors.blue, size: 40),
            ),
            const SizedBox(height: 20),
            Text(
              'Tu Escudo Financiero',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
            ),
            const SizedBox(height: 10),
            Text(
              'Aprende qué es el fondo de emergencia y por qué es la clave definitiva para tu tranquilidad.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            ),
            const SizedBox(height: 30),

            // Sección 1
            _buildSection(
              title: '¿Qué es el Fondo de Emergencia?',
              color: Colors.blue,
              content: 'Es una reserva de dinero guardada exclusivamente para hacer frente a gastos imprevistos y urgentes: emergencias médicas, reparaciones mecánicas del carro, daños en el hogar o la pérdida repentina del empleo. No es dinero para vacaciones ni antojos.',
            ),
            const SizedBox(height: 20),

            // Sección 2
            _buildSection(
              title: 'La Regla de los 3 a 6 meses',
              color: Colors.indigo,
              content: 'Tu meta ideal a mediano plazo debe ser acumular el equivalente a entre 3 y 6 meses de tus gastos básicos de vida. Si tus gastos indispensables en Guatemala son de Q4,000 mensuales, tu fondo completo debería oscilar entre Q12,000 y Q24,000.',
            ),
            const SizedBox(height: 20),

            // Sección 3
            _buildSection(
              title: 'Empieza Pequeño (Meta Inicial)',
              color: Colors.teal,
              content: 'No intentes llenar la meta completa de golpe o te vas a asfixiar. Enfócate en tu primera victoria rápida: junta un "mini-fondo" de Q1,000 a Q3,000 libres. Este pequeño amortiguador evitará que caigas en deudas con tarjetas ante cualquier percance menor.',
            ),
            const SizedBox(height: 40),

            // Botón Entendido
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  '¡Entendido!',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Color color, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.4),
          ),
        ],
      ),
    );
  }
}