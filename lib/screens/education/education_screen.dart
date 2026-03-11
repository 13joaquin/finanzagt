import 'package:flutter/material.dart';
import 'lesson/lesson_50_30_20_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // AppBar invisible para mantener el color de fondo, pero útil para la estructura
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Oculta flecha de regreso al estar en el menú inferior
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TÍTULO Y SUBTÍTULO
            Text(
              'Educación',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aprende a dominar tu dinero ahora',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 30),

            // LISTA DE LECCIONES (WIDGETS)
            _buildLessonCard(
              context: context,
              title: 'La Regla 50/30/20',
              description: 'El método definitivo para organizar tu presupuesto mensual.',
              icon: Icons.pie_chart_rounded,
              color: Colors.blue,

            ),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'Fondo de Emergencia',
              description: 'Tu escudo financiero contra imprevistos y deudas sorpresa.',
              icon: Icons.health_and_safety_rounded,
              color: const Color(0xFF2E7D32), // Verde Finavid
            ),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'Automatiza tu Ahorro',
              description: 'Págate a ti mismo primero sin tener que pensarlo.',
              icon: Icons.autorenew_rounded,
              color: Colors.purple,

            ),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'Evita la Inflación de Estilo de Vida',
              description: 'Ganas más, pero... ¿por qué sientes que tienes menos?',
              icon: Icons.trending_down_rounded,
              color: Colors.orange,
            ),

            const SizedBox(height: 80), // Espacio para el botón flotante del menú
          ],
        ),
      ),
    );
  }

  // WIDGET REUTILIZABLE PARA CADA LECCIÓN
  Widget _buildLessonCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,

  }) {
    return InkWell(
      onTap: () {
        // AQUÍ IRÁ LA NAVEGACIÓN A LAS PANTALLAS DE LECTURA MÁS ADELANTE
        //debugPrint("Abrir lección: $title");
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Lesson503020Screen()));
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea todo arriba
          children: [
            // ÍCONO DE LA LECCIÓN
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 15),

            // TEXTOS (TÍTULO Y DESCRIPCIÓN)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // BOMBILLA AMARILLA EN LA ESQUINA SUPERIOR DERECHA
            const Icon(
              Icons.lightbulb_rounded,
              color: Colors.amber,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}