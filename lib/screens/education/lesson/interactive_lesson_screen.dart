import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:finanzagt/data/models/lesson_model.dart';
import 'package:finanzagt/providers/lesson_provider.dart';

class InteractiveLessonScreen extends StatefulWidget {
  final LessonModel lesson;

  const InteractiveLessonScreen({super.key, required this.lesson});

  @override
  State<InteractiveLessonScreen> createState() => _InteractiveLessonScreenState();
}

class _InteractiveLessonScreenState extends State<InteractiveLessonScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  int? _selectedAnswer;
  bool _hasAnswered = false;

  @override
  void initState() {
    super.initState();
    // Reinicia las vidas al entrar a una lección
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<LessonProvider>(context, listen: false).resetLesson();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _checkAnswer(int optionIndex, LessonStep step) {
    if (_hasAnswered) return;

    final provider = Provider.of<LessonProvider>(context, listen: false);
    bool isCorrect = (step.correctOptionIndex == null) || (optionIndex == step.correctOptionIndex);

    setState(() {
      _selectedAnswer = optionIndex;
      _hasAnswered = true;
    });

    bool success = provider.submitAnswer(isCorrect, widget.lesson.steps.length, _currentIndex);

    if (!success && step.correctOptionIndex != null) {
      _showErrorBottomSheet(provider.lives);
    }
  }

  void _showErrorBottomSheet(int remainingLives) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.red[50],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.close_rounded, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                const Text('¡Respuesta Incorrecta!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Te quedan $remainingLives vidas ❤️', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (remainingLives == 0) {
                    Navigator.pop(context); // Saca al usuario si perdió todas las vidas
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('ENTENDIDO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _nextStep() {
    final provider = Provider.of<LessonProvider>(context, listen: false);

    if (_currentIndex < widget.lesson.steps.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() {
        _currentIndex++;
        _selectedAnswer = null;
        _hasAnswered = false;
      });
      // Avanzar progreso si no era pregunta (solo lectura)
      if (widget.lesson.steps[_currentIndex-1].correctOptionIndex == null) {
        provider.submitAnswer(true, widget.lesson.steps.length, _currentIndex-1);
      }
    } else {
      // 🎉 ¡LECCIÓN COMPLETADA!
      provider.markLessonAsCompleted(widget.lesson.id);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Completaste ${widget.lesson.title}!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<LessonProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER DUOLINGO STYLE ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.grey),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: provider.progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: List.generate(3, (index) => Icon(
                      index < provider.lives ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red, size: 28,
                    )),
                  ),
                ],
              ),
            ),

            // --- CONTENIDO DINÁMICO ---
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.lesson.steps.length,
                itemBuilder: (context, index) {
                  final step = widget.lesson.steps[index];
                  bool isQuestion = step.question != null;

                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(step.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                        const SizedBox(height: 16),
                        Text(step.content, style: const TextStyle(fontSize: 16, color: Colors.black87, height: 1.5)),
                        const SizedBox(height: 32),

                        if (isQuestion) ...[
                          Text(step.question!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 20),
                          ...List.generate(step.options!.length, (optIndex) {
                            return _buildOptionButton(
                              text: step.options![optIndex],
                              index: optIndex,
                              step: step,
                            );
                          }),
                        ],
                        const Spacer(),
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            onPressed: (isQuestion && !_hasAnswered) ? null : _nextStep,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (isQuestion && !_hasAnswered) ? Colors.grey[300] : const Color(0xFF4A47F6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              _currentIndex == widget.lesson.steps.length - 1 ? 'FINALIZAR LECCIÓN' : 'CONTINUAR',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: (isQuestion && !_hasAnswered) ? Colors.grey[600] : Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({required String text, required int index, required LessonStep step}) {
    Color getBorderColor() {
      if (!_hasAnswered) return Colors.grey[300]!;
      if (index == step.correctOptionIndex) return Colors.green;
      if (index == _selectedAnswer) return Colors.red;
      return Colors.grey[300]!;
    }
    Color getBackgroundColor() {
      if (!_hasAnswered) return Colors.white;
      if (index == step.correctOptionIndex) return Colors.green.withOpacity(0.1);
      if (index == _selectedAnswer) return Colors.red.withOpacity(0.1);
      return Colors.white;
    }

    return GestureDetector(
      onTap: () => _checkAnswer(index, step),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: getBackgroundColor(),
          border: Border.all(color: getBorderColor(), width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}