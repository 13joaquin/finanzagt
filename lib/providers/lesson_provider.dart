import 'package:flutter/material.dart';

class LessonProvider extends ChangeNotifier {
  // Estado de la lección
  int _lives = 3;
  double _progress = 0.0; // De 0.0 a 1.0
  bool _isLessonCompleted = false;
  bool _isGameOver = false;

  // Getters para que la UI consuma el estado
  int get lives => _lives;
  double get progress => _progress;
  bool get isLessonCompleted => _isLessonCompleted;
  bool get isGameOver => _isGameOver;

  /// Simulación de pasos para la lección de la regla 50/30/20
  /// En una fase posterior, esto puede venir de Firestore.
  final List<double> _progressSteps = [0.15, 0.40, 1.0];
  int _currentStepIndex = 0;

  /// Valida la respuesta del usuario en la trivia.
  /// Retorna [true] si la respuesta es correcta, [false] si es incorrecta.
  bool submitAnswer(bool isCorrect) {
    if (isGameOver || _isLessonCompleted) return false;

    if (isCorrect) {
      _advanceProgress();
      return true;
    } else {
      _loseLife();
      return false;
    }
  }

  /// Resta una vida y verifica si el usuario ha perdido.
  void _loseLife() {
    if (_lives > 0) {
      _lives--;
      if (_lives == 0) {
        _isGameOver = true;
      }
      notifyListeners();
    }
  }

  /// Avanza el progreso según los pasos definidos.
  void _advanceProgress() {
    if (_currentStepIndex < _progressSteps.length) {
      _progress = _progressSteps[_currentStepIndex];
      _currentStepIndex++;

      if (_progress >= 1.0) {
        _isLessonCompleted = true;
      }
      notifyListeners();
    }
  }

  /// Reinicia el estado para volver a intentar la lección.
  /// Ideal para el botón de "Reintentar" en la pantalla de Game Over.
  void resetLesson() {
    _lives = 3;
    _progress = 0.0;
    _isLessonCompleted = false;
    _isGameOver = false;
    _currentStepIndex = 0;
    notifyListeners();
  }
}