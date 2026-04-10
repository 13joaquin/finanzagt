import 'package:flutter/material.dart';
// Importa tus pantallas de lecciones
import 'lesson/lesson_50_30_20_screen.dart';
import 'lesson/emergency_fund_edu_screen.dart';

class EducationScreen extends StatelessWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CABECERA DE LA ACADEMIA ---
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A47F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.school_rounded, color: Color(0xFF4A47F6), size: 32),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academia Finavid',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                      ),
                      Text(
                        'Domina tu dinero, paso a paso.',
                        style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),

            // --- MÓDULO 1: FUNDAMENTOS ---
            _buildSectionTitle('Nivel 1: Fundamentos', Icons.foundation),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'El Escudo Financiero',
              description: 'Aprende qué es el fondo de emergencia y por qué te da paz mental.',
              icon: Icons.security_rounded,
              color: const Color(0xFF1976D2), // Azul
              isLocked: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyFundEduScreen() ));
              },
            ),

            _buildLessonCard(
              context: context,
              title: 'La Regla 50/30/20',
              description: 'El mapa más sencillo para distribuir tu salario sin estrés.',
              icon: Icons.pie_chart_rounded,
              color: const Color(0xFFE64A19), // Naranja
              isLocked: false,
              onTap: () {
                // Asegúrate de que esta pantalla exista, o coméntala temporalmente
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Lesson503020Screen()));
              },
            ),

            const SizedBox(height: 30),

            // --- MÓDULO 2: CRECIMIENTO (Próximamente) ---
            _buildSectionTitle('Nivel 2: Crecimiento', Icons.trending_up_rounded),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'Inflación de Estilo de Vida',
              description: 'Ganas más, pero el dinero no alcanza. ¿Por qué ocurre esto?',
              icon: Icons.shopping_bag_rounded,
              color: Colors.grey, // Gris porque está bloqueado
              isLocked: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Termina el Nivel 1 para desbloquear esta lección.')),
                );
              },
            ),

            const SizedBox(height: 100), // Espacio para que el menú inferior no tape contenido
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA TÍTULOS DE SECCIÓN ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey[800], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
        ),
      ],
    );
  }

  // --- WIDGET PARA TARJETAS DE LECCIÓN ---
  Widget _buildLessonCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(color: isLocked ? Colors.transparent : color.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Ícono de la lección
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey[100] : color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(isLocked ? Icons.lock_rounded : icon, color: isLocked ? Colors.grey[400] : color, size: 30),
                ),
                const SizedBox(width: 15),
                // Textos
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isLocked ? Colors.grey[600] : Colors.blueGrey[900],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Botón Play o Candado
                Icon(
                  isLocked ? Icons.lock_outline : Icons.play_circle_fill_rounded,
                  color: isLocked ? Colors.grey[300] : color,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}