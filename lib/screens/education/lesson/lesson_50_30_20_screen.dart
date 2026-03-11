import 'package:flutter/material.dart';

class Lesson503020Screen extends StatelessWidget {
  const Lesson503020Screen({super.key});

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
          child: const Icon(Icons.pie_chart_rounded, color: Colors.blue, size: 40),
        ),
        const SizedBox(height: 20),
        Text('La Regla 50/30/20', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
        const SizedBox(height: 10),
        Text('El método definitivo para organizar tu presupuesto mensual sin sentirte asfixiado.', style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5)),
        const SizedBox(height: 30),

        // Ilustración visual


        const SizedBox(height: 30),
    _buildSection(
    title: '50% - Necesidades (Gastos Fijos)',
    color: Colors.blue,
    content: 'Es la mitad de tus ingresos. Va destinado a lo que necesitas para sobrevivir: Alquiler, hipoteca, servicios básicos (luz, agua), alimentación básica y transporte para ir al trabajo. Si no lo pagas, hay consecuencias graves.',
    ),
    const SizedBox(height: 20),
    _buildSection(
    title: '30% - Deseos (Flexibles y Ocio)',
    color: Colors.orange,
    content: 'Tu zona libre de culpa. Aquí entra Netflix, salir a cenar, ese café de especialidad, ropa nueva que no es urgente o ir al cine. Es lo que le da "sabor" a la vida. ¡Pero cuidado con pasarte del 30%!',
    ),
    const SizedBox(height: 20),
    _buildSection(
    title: '20% - Ahorro e Inversión',
    color: const Color(0xFF2E7D32),
    content: 'Este dinero es para tu "yo del futuro". Fondo de emergencia, aportes para el retiro, abonos extra a deudas o inversiones. Págate a ti mismo primero.',
    ),
    const SizedBox(height: 40),
    SizedBox(
    width: double.infinity,
    height: 50,
    child: ElevatedButton(
    onPressed: () => Navigator.pop(context),
    style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey[900], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
    child: const Text('¡Entendido!', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    ),
    )
    ],
    ),
    ),
    );
  }

  Widget _buildSection({required String title, required Color color, required String content}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 10),
          Text(content, style: TextStyle(fontSize: 15, color: Colors.blueGrey[800], height: 1.5)),
        ],
      ),
    );
  }
}