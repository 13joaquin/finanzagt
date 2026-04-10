import 'dart:async';
import 'package:flutter/material.dart';

class EmergencyFundEduScreen extends StatefulWidget {
  const EmergencyFundEduScreen({super.key});

  @override
  State<EmergencyFundEduScreen> createState() => _EmergencyFundEduScreenState();
}

class _EmergencyFundEduScreenState extends State<EmergencyFundEduScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animController;
  int _currentIndex = 0;

  // Definición de las "Historias"
  final List<Map<String, dynamic>> _stories = [
    {
      'title': 'Tu Escudo Financiero',
      'content': 'Un Fondo de Emergencia es dinero guardado EXCLUSIVAMENTE para imprevistos: emergencias médicas, reparaciones del hogar o desempleo.',
      'icon': Icons.security_rounded,
      'color': const Color(0xFF1A237E),
    },
    {
      'title': 'Paz Mental',
      'content': 'No es solo dinero; es la seguridad de saber que si algo sale mal hoy, no tendrás que endeudarte mañana. Te da libertad de elección.',
      'icon': Icons.self_improvement_rounded,
      'color': const Color(0xFF0D47A1),
    },
    {
      'title': 'La Regla de 3 a 6',
      'content': 'Tu meta ideal debe ser cubrir entre 3 y 6 meses de tus gastos básicos. Si gastas Q4,000 al mes, tu fondo ideal es de Q12,000 a Q24,000.',
      'icon': Icons.rule_rounded,
      'color': const Color(0xFF1976D2),
    },
    {
      'title': 'Empieza Pequeño',
      'content': 'No intentes llenarlo en un mes. Automatiza el 5% o 10% de tu ingreso. Lo importante es la constancia, no la cantidad inicial.',
      'icon': Icons.auto_graph_rounded,
      'color': const Color(0xFF2196F3),
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(vsync: this);

    // CORRECCIÓN: Esperamos a que la pantalla se dibuje por completo
    // antes de arrancar la primera historia.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStory(index: 0, animateToPage: false);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _loadStory({int index = 0, bool animateToPage = true}) {
    _animController.stop();
    _animController.reset();
    _animController.duration = const Duration(seconds: 5);
    _animController.forward();

    if (animateToPage) {
      _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }

    _animController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animController.stop();
        _animController.reset();
        setState(() {
          if (_currentIndex + 1 < _stories.length) {
            _currentIndex++;
            _loadStory(index: _currentIndex);
          } else {
            // Fin de las historias
            Navigator.pop(context);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) => _onTapDown(details),
        child: Stack(
          children: [
            // Contenido de la Página
            PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Evitamos swipe manual para controlar el tiempo
              itemCount: _stories.length,
              itemBuilder: (context, index) {
                final story = _stories[index];
                return _StoryWidget(story: story);
              },
            ),

            // Barras de Progreso Superiores
            Positioned(
              top: 60, left: 10, right: 10,
              child: Row(
                children: _stories.asMap().entries.map((entry) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: AnimatedBar(
                        animController: _animController,
                        position: entry.key,
                        currentIndex: _currentIndex,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            // Botón de Cerrar
            Positioned(
              top: 50, right: 10,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double dx = details.globalPosition.dx;

    if (dx < screenWidth / 3) {
      // Tap a la izquierda: Retroceder
      setState(() {
        if (_currentIndex - 1 >= 0) {
          _currentIndex--;
          _loadStory(index: _currentIndex);
        }
      });
    } else {
      // Tap a la derecha: Avanzar
      setState(() {
        if (_currentIndex + 1 < _stories.length) {
          _currentIndex++;
          _loadStory(index: _currentIndex);
        } else {
          Navigator.pop(context); // Cerrar al terminar
        }
      });
    }
  }
}

class _StoryWidget extends StatelessWidget {
  final Map<String, dynamic> story;
  const _StoryWidget({required this.story});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [story['color'], Colors.black],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(story['icon'], size: 120, color: Colors.white),
          const SizedBox(height: 40),
          Text(
            story['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Text(
            story['content'],
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18, height: 1.5),
          ),
          const SizedBox(height: 50),
          if (story['title'] == 'Empieza Pequeño')
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
              ),
              child: const Text('¡ENTENDIDO!', style: TextStyle(fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  final AnimationController animController;
  final int position;
  final int currentIndex;

  const AnimatedBar({
    super.key,
    required this.animController,
    required this.position,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            _buildContainer(
              double.infinity,
              position < currentIndex ? Colors.white : Colors.white.withOpacity(0.3),
            ),
            position == currentIndex
                ? AnimatedBuilder(
              animation: animController,
              builder: (context, child) {
                return _buildContainer(
                  constraints.maxWidth * animController.value,
                  Colors.white,
                );
              },
            )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }

  Container _buildContainer(double width, Color color) {
    return Container(
      height: 4.0,
      width: width,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black26, width: 0.8),
        borderRadius: BorderRadius.circular(3.0),
      ),
    );
  }
}