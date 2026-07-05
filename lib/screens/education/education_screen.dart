// Archivo: lib/screens/education/education_screen.dart
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
        // CORRECCIÓN: Botón explícito para regresar al Dashboard inicial
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
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
              color: const Color(0xFF1976D2),
              isLocked: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyFundEduScreen()));
              },
            ),

            _buildLessonCard(
              context: context,
              title: 'La Regla 50/30/20',
              description: 'El mapa más sencillo para distribuir tu salario sin estrés.',
              icon: Icons.pie_chart_rounded,
              color: const Color(0xFFE64A19),
              isLocked: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Lesson503020Screen()));
              },
            ),

            const SizedBox(height: 30),

            // --- MÓDULO 2: CRECIMIENTO ---
            _buildSectionTitle('Nivel 2: Crecimiento', Icons.trending_up_rounded),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'Inflación de Estilo de Vida',
              description: 'Ganas más, pero el dinero no alcanza. ¿Por qué ocurre esto?',
              icon: Icons.shopping_bag_rounded,
              color: Colors.grey,
              isLocked: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Termina el Nivel 1 para desbloquear esta lección.')),
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

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

  Widget _buildLessonCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLocked,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(isLocked ? Icons.lock_rounded : icon, color: isLocked ? Colors.grey[400] : color, size: 30),
              ),
              const SizedBox(width: 15),
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
              Icon(
                isLocked ? Icons.lock_outline : Icons.play_circle_fill_rounded,
                color: isLocked ? Colors.grey[300] : color,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}