import 'package:flutter/material.dart';
import 'package:finanzagt/data/models/lesson_model.dart';

class InteractiveLessonScreen extends StatefulWidget {
  final LessonModel lesson;

  const InteractiveLessonScreen({super.key, required this.lesson});

  @override
  State<InteractiveLessonScreen> createState() => _InteractiveLessonScreenState();
}

class _InteractiveLessonScreenState extends State<InteractiveLessonScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int _hearts = 3; // Sistema de vidas gamificado
  int? _selectedAnswer;
  bool _hasAnswered = false;

  void _checkAnswer(int index, LessonStep step) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswer = index;
      _hasAnswered = true;
      if (index != step.correctOptionIndex) {
        _hearts = (_hearts - 1).clamp(0, 3);
      }
    });
  }

  void _nextStep() {
    if (_hearts == 0) {
      // Lógica de "Has perdido tus vidas" (puede ser un Dialog que reinicie)
      Navigator.pop(context);
      return;
    }

    if (_currentIndex < widget.lesson.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
      });
    } else {
      // Fin de la lección - Aquí podrías actualizar Firebase Firestore
      Navigator.pop(context, true); // Retorna true al completar
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final double progress = (_currentIndex + 1) / widget.lesson.steps.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Expanded(
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.favorite, color: Colors.redAccent, size: 24),
            const SizedBox(width: 4),
            Text(
              '$_hearts',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Evita deslizar libremente
        itemCount: widget.lesson.steps.length,
        itemBuilder: (context, index) {
          final step = widget.lesson.steps[index];
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Text(
                  step.content,
                  style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                ),
                const SizedBox(height: 32),
                if (step.question != null) ...[
                  Text(
                    step.question!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(
                    step.options!.length,
                        (optIndex) => _buildOptionButton(
                      text: step.options![optIndex],
                      index: optIndex,
                      step: step,
                    ),
                  ),
                ],
                const Spacer(),
                ElevatedButton(
                  onPressed: (step.question != null && !_hasAnswered) ? null : _nextStep,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _currentIndex == widget.lesson.steps.length - 1 ? 'Finalizar' : 'Continuar',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionButton({required String text, required int index, required LessonStep step}) {
    Color getBorderColor() {
      if (!_hasAnswered) return Colors.grey.shade300;
      if (index == step.correctOptionIndex) return Colors.green;
      if (index == _selectedAnswer) return Colors.red;
      return Colors.grey.shade300;
    }

    Color getBackgroundColor() {
      if (!_hasAnswered) return Colors.white;
      if (index == step.correctOptionIndex) return Colors.green.withOpacity(0.1);
      if (index == _selectedAnswer) return Colors.red.withOpacity(0.1);
      return Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () => _checkAnswer(index, step),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: getBackgroundColor(),
            border: Border.all(color: getBorderColor(), width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ),
    );
  }
}