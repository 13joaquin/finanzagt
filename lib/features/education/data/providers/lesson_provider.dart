// Archivo: lib/providers/lesson_provider.dart
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lessonProvider = NotifierProvider<LessonProvider, LessonState>(
  LessonProvider.new,
);

// --- Estado inmutable de la Lección/Progreso Educativo ---
// Agrupa lo que antes eran campos privados del ChangeNotifier, siguiendo
// el mismo patrón ya usado por BudgetState en budget_provider.dart.
class LessonState {
  final int lives;
  final double progress;
  final bool isLessonCompleted;
  final bool isGameOver;
  final List<String> completedLessons;

  const LessonState({
    this.lives = 3,
    this.progress = 0.0,
    this.isLessonCompleted = false,
    this.isGameOver = false,
    this.completedLessons = const [],
  });

  LessonState copyWith({
    int? lives,
    double? progress,
    bool? isLessonCompleted,
    bool? isGameOver,
    List<String>? completedLessons,
  }) {
    return LessonState(
      lives: lives ?? this.lives,
      progress: progress ?? this.progress,
      isLessonCompleted: isLessonCompleted ?? this.isLessonCompleted,
      isGameOver: isGameOver ?? this.isGameOver,
      completedLessons: completedLessons ?? this.completedLessons,
    );
  }
}

class LessonProvider extends Notifier<LessonState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  // Getters (mismo contrato público que el ChangeNotifier original)
  int get lives => state.lives;
  double get progress => state.progress;
  bool get isLessonCompleted => state.isLessonCompleted;
  bool get isGameOver => state.isGameOver;
  List<String> get completedLessons => state.completedLessons;

  @override
  LessonState build() {
    return const LessonState();
  }

  /// Método inicializador. Debe llamarse cuando se conoce el UID del usuario
  /// (por ejemplo desde la pantalla de Educación o desde el Bootstrap),
  /// para que el provider sepa de qué usuario buscar el progreso.
  Future<void> initializeUser(String? uid) async {
    if (uid == null || uid == _userId) return; // Evitar recargas innecesarias

    _userId = uid;
    state = state.copyWith(completedLessons: []);

    try {
      // Leemos la subcolección de progreso del usuario
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('education_progress')
          .get();

      // Guardamos en el estado los IDs de las lecciones completadas
      state = state.copyWith(
        completedLessons: snapshot.docs.map((doc) => doc.id).toList(),
      );
    } catch (e) {
      debugPrint("Error cargando el progreso educativo desde Firestore: $e");
    }
  }
  void resetUser(){
    _userId = null;
    state = state.copyWith(
      completedLessons: [],
      lives: 3,
      progress: 0.0,
      isLessonCompleted: false,
      isGameOver: false,
    );
  }
  // Verifica si una lección específica ya fue completada
  bool isLessonDone(String lessonId) {
    return state.completedLessons.contains(lessonId);
  }

  // Marca una lección como completada y la guarda en la nube
  Future<void> markLessonAsCompleted(String lessonId) async {
    if (!state.completedLessons.contains(lessonId)) {
      // 1. Actualización optimista en la UI (se refleja de inmediato sin esperar la red)
      state = state.copyWith(
        completedLessons: [...state.completedLessons, lessonId],
      );

      // 2. Guardado persistente en Firestore
      if (_userId != null) {
        try {
          await _firestore
              .collection('users')
              .doc(_userId)
              .collection('education_progress')
              .doc(lessonId)
              .set({
            'completedAt': FieldValue.serverTimestamp(),
            'status': 'completed',
          });
        } catch (e) {
          debugPrint("Error guardando la lección en Firestore: $e");
          // Opcional: Podrías hacer un rollback aquí si la red falla
        }
      }
    }
  }

  // Lógica de validación de respuestas
  bool submitAnswer(bool isCorrect, int totalSteps, int currentStep) {
    if (state.isGameOver || state.isLessonCompleted) return false;

    if (isCorrect) {
      _advanceProgress(totalSteps, currentStep);
      return true;
    } else {
      _loseLife();
      return false;
    }
  }

  void _loseLife() {
    if (state.lives > 0) {
      final newLives = state.lives - 1;
      state = state.copyWith(
        lives: newLives,
        isGameOver: newLives == 0,
      );
    }
  }

  void _advanceProgress(int totalSteps, int currentStep) {
    final newProgress = (currentStep + 1) / totalSteps;
    state = state.copyWith(
      progress: newProgress,
      isLessonCompleted: newProgress >= 1.0,
    );
  }

  void resetLesson() {
    state = state.copyWith(
      lives: 3,
      progress: 0.0,
      isLessonCompleted: false,
      isGameOver: false,
    );
  }
}