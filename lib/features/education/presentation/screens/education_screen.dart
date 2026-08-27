// Archivo: education/education_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../data/lesson_data.dart';
import '../../data/models/lesson_model.dart';
import '../../data/providers/lesson_provider.dart';
import 'lesson/interactive_lesson_screen.dart';

class EducationScreen extends ConsumerWidget {
  const EducationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Escuchamos el estado del usuario (para saber si es PRO)
    final user = ref.watch(userProvider);
    final isPro = user?.isPro ?? false;

    // Escuchamos el progreso de las lecciones
    final lessonState = ref.watch(lessonProvider);

    // Separamos las lecciones por nivel
    final nivel1Lessons = appLessonsRoute
        .where((l) => l.level == 'Nivel 1')
        .toList();
    final nivel2Lessons = appLessonsRoute
        .where((l) => l.level == 'Nivel 2')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
          ),
          onPressed: () => Navigator.of(context).pop(),
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
                    color: const Color(0xFF4A47F6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF4A47F6),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Academia Finavid',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey[900],
                        ),
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

            ...nivel1Lessons.map((lesson) {
              final isCompleted = lessonState.completedLessons.contains(
                lesson.id,
              );
              return _buildLessonCard(
                context: context,
                lesson: lesson,
                isCompleted: isCompleted,
                isLocked: false, // Nivel 1 siempre está desbloqueado
                color: const Color(0xFF1976D2),
              );
            }),

            const SizedBox(height: 30),

            // --- MÓDULO 2: CRECIMIENTO ---
            _buildSectionTitle(
              'Nivel 2: Crecimiento',
              Icons.trending_up_rounded,
            ),
            const SizedBox(height: 15),

            ...nivel2Lessons.map((lesson) {
              final isCompleted = lessonState.completedLessons.contains(
                lesson.id,
              );
              final isLocked = !isPro; // Se bloquea si no es PRO

              return _buildLessonCard(
                context: context,
                lesson: lesson,
                isCompleted: isCompleted,
                isLocked: isLocked,
                color: const Color(0xFFE64A19),
              );
            }),

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
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueGrey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard({
    required BuildContext context,
    required LessonModel lesson,
    required bool isCompleted,
    required bool isLocked,
    required Color color,
  }) {
    // Si la lección está bloqueada, mostramos tonos grises.
    final cardColor = isLocked ? Colors.grey : color;

    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isCompleted
              ? Colors.green.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.15),
          width: isCompleted ? 2 : 1,
        ),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          if (isLocked) {
            _showProPaywall(context);
          } else {
            // ¡MAGIA! Navegamos al reproductor interactivo pasando los datos de la lección.
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InteractiveLessonScreen(lesson: lesson),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Ícono Circular
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green.withValues(alpha: 0.1)
                      : cardColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check_circle_rounded
                      : (isLocked ? Icons.lock_rounded : lesson.icon),
                  color: isCompleted
                      ? Colors.green
                      : (isLocked ? Colors.grey[400] : cardColor),
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              // Textos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lesson.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isLocked
                                  ? Colors.grey[600]
                                  : Colors.blueGrey[900],
                            ),
                          ),
                        ),
                        // Etiqueta PRO
                        if (lesson.isPremium && isLocked)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'PRO',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      lesson.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Botón de Play
              Icon(
                isLocked ? Icons.lock_outline : Icons.play_circle_fill_rounded,
                color: isLocked ? Colors.grey[300] : cardColor,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProPaywall(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.workspace_premium_rounded,
              color: Colors.amber,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nivel PRO Requerido',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Para desbloquear el Nivel 2 y aprender sobre Inflación de Estilo, Deudas e Inversión, necesitas actualizar a Finavid PRO.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context), // Aquí irá la pasarela luego
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[800],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'VER PLANES PRO',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
