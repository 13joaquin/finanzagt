// Archivo: lib/providers/lesson_provider.dart
import 'package:flutter/material.dart';

class LessonProvider extends ChangeNotifier {
  // --- Estado de la Lección Actual ---
  int _lives = 3;
  double _progress = 0.0;
  bool _isLessonCompleted = false;
  bool _isGameOver = false;

  // --- Progreso Global (Memoria Local por ahora) ---
  final List<String> _completedLessons = [];

  // Getters
  int get lives => _lives;
  double get progress => _progress;
  bool get isLessonCompleted => _isLessonCompleted;
  bool get isGameOver => _isGameOver;
  List<String> get completedLessons => _completedLessons;

  // Verifica si una lección específica ya fue completada
  bool isLessonDone(String lessonId) {
    return _completedLessons.contains(lessonId);
  }

  // Marca una lección como completada en la ruta
  void markLessonAsCompleted(String lessonId) {
    if (!_completedLessons.contains(lessonId)) {
      _completedLessons.add(lessonId);
      notifyListeners();
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