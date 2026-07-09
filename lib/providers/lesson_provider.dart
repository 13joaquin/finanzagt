// Archivo: lib/providers/lesson_provider.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LessonProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;

  // --- Estado de la Lección Actual ---
  int _lives = 3;
  double _progress = 0.0;
  bool _isLessonCompleted = false;
  bool _isGameOver = false;

  // --- Progreso Global (Sincronizado con Firestore) ---
  List<String> _completedLessons = [];

  // Getters
  int get lives => _lives;
  double get progress => _progress;
  bool get isLessonCompleted => _isLessonCompleted;
  bool get isGameOver => _isGameOver;
  List<String> get completedLessons => _completedLessons;

  /// Método inicializador. Llama a esto desde tu main.dart o en el ProxyProvider
  /// para que el proveedor sepa de qué usuario buscar el progreso.
  Future<void> initializeUser(String? uid) async {
    if (uid == null || uid == _userId) return; // Evitar recargas innecesarias

    _userId = uid;
    _completedLessons = [];

    try {
      // Leemos la subcolección de progreso del usuario
      final snapshot = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('education_progress')
          .get();

      // Guardamos en la memoria local los IDs de las lecciones completadas
      _completedLessons = snapshot.docs.map((doc) => doc.id).toList();
      notifyListeners();
    } catch (e) {
      debugPrint("Error cargando el progreso educativo desde Firestore: $e");
    }
  }

  // Verifica si una lección específica ya fue completada
  bool isLessonDone(String lessonId) {
    return _completedLessons.contains(lessonId);
  }

  // Marca una lección como completada y la guarda en la nube
  Future<void> markLessonAsCompleted(String lessonId) async {
    if (!_completedLessons.contains(lessonId)) {
      // 1. Actualización optimista en la UI (se refleja de inmediato sin esperar la red)
      _completedLessons.add(lessonId);
      notifyListeners();

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
    if (isGameOver || _isLessonCompleted) return false;

    if (isCorrect) {
      _advanceProgress(totalSteps, currentStep);
      return true;
    } else {
      _loseLife();
      return false;
    }
  }

  void _loseLife() {
    if (_lives > 0) {
      _lives--;
      if (_lives == 0) {
        _isGameOver = true;
      }
      notifyListeners();
    }
  }

  void _advanceProgress(int totalSteps, int currentStep) {
    _progress = (currentStep + 1) / totalSteps;
    if (_progress >= 1.0) {
      _isLessonCompleted = true;
    }
    notifyListeners();
  }

  void resetLesson() {
    _lives = 3;
    _progress = 0.0;
    _isLessonCompleted = false;
    _isGameOver = false;
    notifyListeners();
  }
}