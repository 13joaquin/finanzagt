import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../auth/presentation/providers/user_provider.dart';
import '../../../data/lesson_data.dart';
import '../../../data/models/lesson_model.dart';
import '../../../data/providers/lesson_provider.dart';
import 'emergency_fund_edu_screen.dart';

class LearningPathScreen extends ConsumerWidget {
  const LearningPathScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Estado real de las lecciones (reemplaza al estado simulado)
    final lessonState = ref.watch(lessonProvider);

    // Estado real del usuario (reemplaza a isUserPro = false)
    final user = ref.watch(userProvider);
    final isUserPro = user?.isPro ?? false;

    // La lección actual es la primera de la ruta que todavía no está completada.
    // Se deriva aquí, sin agregar estado nuevo a LessonProvider.
    final currentLessonIndex = appLessonsRoute.indexWhere(
          (lesson) => !lessonState.completedLessons.contains(lesson.id),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Fondo neutro claro
      appBar: AppBar(
        title: const Text(
          'Ruta Finavid',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 40),
        itemCount: appLessonsRoute.length,
        itemBuilder: (context, index) {
          final lesson = appLessonsRoute[index];

          // Lógica de estado de la lección (derivada del estado real)
          final isCompleted = lessonState.completedLessons.contains(lesson.id);
          final isCurrent =
              currentLessonIndex != -1 && index == currentLessonIndex;
          final isLocked = !isCompleted && !isCurrent;
          final requiresProUpgrade = lesson.isPremium && !isUserPro;

          // Efecto Zig-Zag (Izquierda, Centro, Derecha)
          final double alignmentX = index.isEven ? -0.4 : 0.4;

          return _buildPathNode(
            context: context,
            lesson: lesson,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isLocked: isLocked,
            requiresProUpgrade: requiresProUpgrade,
            alignmentX: alignmentX,
            isLast: index == appLessonsRoute.length - 1,
          );
        },
      ),
    );
  }

  Widget _buildPathNode({
    required BuildContext context,
    required LessonModel lesson,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required bool requiresProUpgrade,
    required double alignmentX,
    required bool isLast,
  }) {
    // Definimos colores basados en el estado
    Color nodeColor;
    if (isCompleted) {
      nodeColor = const Color(0xFF4CAF50); // Verde - Completado
    } else if (isCurrent) {
      nodeColor = const Color(0xFF2196F3); // Azul - Activo
    } else {
      nodeColor = const Color(0xFFE0E0E0); // Gris - Bloqueado
    }

    return Column(
      children: [
        Align(
          alignment: Alignment(alignmentX, 0),
          child: GestureDetector(
            onTap: () {
              if (requiresProUpgrade) {
                _showProUpgradeDialog(context);
                return;
              }
              if (isLocked) {
                _showLockedSnack(context);
                return;
              }

              // Navegación a la lección activa
              if (lesson.id == 'lesson_03') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EmergencyFundEduScreen(),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Abriendo: ${lesson.title}...')),
                );
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Sombra y Botón Principal
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: nodeColor.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: isCurrent ? Colors.white : Colors.transparent,
                      width: 4,
                    ),
                  ),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle_rounded
                        : requiresProUpgrade
                        ? Icons.workspace_premium_rounded
                        : isLocked
                        ? Icons.lock_rounded
                        : lesson.icon,
                    color: isCompleted
                        ? Colors.white
                        : isLocked && !requiresProUpgrade
                        ? Colors.black38
                        : Colors.white,
                    size: 35,
                  ),
                ),
                // Indicador flotante si es la lección actual
                if (isCurrent)
                  Positioned(
                    top: -15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '¡AQUÍ!',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Título de la lección
        Align(
          alignment: Alignment(alignmentX, 0),
          child: Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            child: Text(
              lesson.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isLocked ? Colors.grey : Colors.black87,
              ),
            ),
          ),
        ),

        // Línea conectora (excepto en el último elemento)
        if (!isLast)
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        if (!isLast) const SizedBox(height: 20),
      ],
    );
  }

  void _showLockedSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Termina las lecciones anteriores para desbloquear esta.',
        ),
        backgroundColor: Colors.black87,
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showProUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🌟 Nivel PRO requerido'),
        content: const Text(
          'Esta lección avanzada sobre Inflación de Estilo está reservada para usuarios PRO. ¿Deseas potenciar tu cuenta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ver Planes'),
          ),
        ],
      ),
    );
  }
}
