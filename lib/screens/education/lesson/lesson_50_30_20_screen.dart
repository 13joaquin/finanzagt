// Archivo: lib/screens/education/lesson/lesson_50_30_20_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Ajusta estas rutas relativas según tu estructura exacta
import '../../../providers/lesson_provider.dart';
import '../../../providers/transaction_provider.dart';

class Lesson503020Screen extends StatefulWidget {
  const Lesson503020Screen({super.key});

  @override
  State<Lesson503020Screen> createState() => _Lesson503020ScreenState();
}

class _Lesson503020ScreenState extends State<Lesson503020Screen> {
  final PageController _pageController = PageController();

// 1. SOLUCIÓN: Nueva variable para rastrear en qué pantalla estamos
  int _currentIndex = 0;

  // Variables de estado local para capturar las respuestas antes de validar
  int? _selectedTriviaOption;
  final TextEditingController _mathController = TextEditingController();
  int? _selectedCommitmentOption;

  @override
  void dispose() {
    _pageController.dispose();
    _mathController.dispose();
    super.dispose();
  }

  void _checkAnswer(bool isCorrect) {
    final lessonProvider = Provider.of<LessonProvider>(context, listen: false);

    // 2. SOLUCIÓN: Enviamos la respuesta, el total de pantallas (4) y el índice actual
    bool success = lessonProvider.submitAnswer(isCorrect, 4, _currentIndex);

    if (success) {
      // 3. SOLUCIÓN: Aumentamos el índice localmente para la barra de progreso
      setState(() {
        _currentIndex++;
      });

      // Avanzar a la siguiente pantalla
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      // Mostrar feedback de error (Bottom Sheet)
      _showErrorBottomSheet(lessonProvider.lives);
    }
  }

  void _showErrorBottomSheet(int remainingLives) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.red[50],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
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
                Text(
                  '¡Respuesta Incorrecta!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.red[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Perdiste una vida: ❤️ -> 💔\nTe quedan $remainingLives vidas.',
              style: TextStyle(fontSize: 16, color: Colors.red[700]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Recuerda: Las necesidades son indispensables para vivir (vivienda, servicios básicos como luz/agua, comida esencial).',
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra el modal
                  if (remainingLives == 0) {
                    Navigator.pop(context); // Saca al usuario de la lección si perdió
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ENTENDIDO',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Escuchamos al provider para dibujar el encabezado
    final lessonProvider = Provider.of<LessonProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // COMPONENTE COMÚN: Encabezado Duolingo-Style
            _buildHeader(lessonProvider),

            // CONTENIDO: Páginas dinámicas
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Evita swipe libre
                children: [
                  _buildPantalla1Trivia(),
                  _buildPantalla2Matematica(),
                  _buildPantalla3EspejoReal(),
                  _buildPantalla4Compromiso(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // WIDGETS PRIVADOS (DISEÑO Y LÓGICA)
  // ==========================================

  Widget _buildHeader(LessonProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.grey),
            onPressed: () {
              provider.resetLesson();
              Navigator.pop(context);
            },
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
          // Dibujar las vidas/corazones
          Row(
            children: List.generate(3, (index) {
              return Icon(
                index < provider.lives ? Icons.favorite : Icons.favorite_border,
                color: Colors.red,
                size: 28,
              );
            }),
          ),
        ],
      ),
    );
  }

  // 🎨 PANTALLA 1: Trivia Rápida
  Widget _buildPantalla1Trivia() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💡 APRENDAMOS CONCEPTOS',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            'Si pagas el recibo de Luz (EEGSA) de tu casa, ¿en qué porcentaje de la regla clasifica?',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900]),
          ),
          const SizedBox(height: 32),
          _buildOptionCard(
              index: 0,
              text: '50% - Necesidades Básicas',
              isSelected: _selectedTriviaOption == 0,
              onTap: () => setState(() => _selectedTriviaOption = 0)),
          _buildOptionCard(
              index: 1,
              text: '30% - Deseos y Gustos',
              isSelected: _selectedTriviaOption == 1,
              onTap: () => setState(() => _selectedTriviaOption = 1)),
          _buildOptionCard(
              index: 2,
              text: '20% - Ahorro e Inversión',
              isSelected: _selectedTriviaOption == 2,
              onTap: () => setState(() => _selectedTriviaOption = 2)),
          const Spacer(),
          _buildComprobarButton(
            isActive: _selectedTriviaOption != null,
            onPressed: () {
              // La respuesta correcta es la 0 (50%)
              _checkAnswer(_selectedTriviaOption == 0);
            },
          ),
        ],
      ),
    );
  }

  // 🎨 PANTALLA 2: Reto Matemático
  Widget _buildPantalla2Matematica() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🧮 EL RETO DE LOS NÚMEROS',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            'Si una persona en Guatemala gana un ingreso mensual de Q5,000...\n\n¿Cuánto es lo MÁXIMO que debería gastar en sus Necesidades Básicas (50%)?',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900]),
          ),
          const SizedBox(height: 40),
          Center(
            child: Container(
              width: 200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Text('Q',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _mathController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Escribe...',
                        hintStyle: TextStyle(fontSize: 18),
                      ),
                      onChanged: (val) => setState(() {}), // Para activar el botón
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          _buildComprobarButton(
            isActive: _mathController.text.isNotEmpty,
            onPressed: () {
              // Q5000 * 0.5 = 2500
              bool isCorrect = _mathController.text.trim() == '2500';
              _checkAnswer(isCorrect);
            },
          ),
        ],
      ),
    );
  }

  // 🎨 PANTALLA 3: Espejo Real (Conexión con el TransactionProvider)
  Widget _buildPantalla3EspejoReal() {
    return Consumer<TransactionProvider>(
      builder: (context, txProvider, child) {
        // Lógica: Calcular el total de ingresos y el gasto en "Deseos"
        double ingresos = txProvider.totalIncomes;

        // Asumiendo que la categoría exacta usada en el App es esta
        double deseosGasto = txProvider.transactions
            .where((t) => t.category == 'Gastos Flexibles y Discrecionales' && t.type == 'expense')
            .fold(0.0, (sum, item) => sum + item.amount);

        // Si es usuario nuevo y no tiene ingresos registrados
        if (ingresos == 0) {
          return _buildEmptyStateEspejoReal();
        }

        double porcentajeDeseos = (deseosGasto / ingresos) * 100;
        bool sePaso = porcentajeDeseos > 30.0;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🔍 TU ESPEJO FINANCIERO',
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: sePaso ? Colors.orange[50] : Colors.green[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: sePaso ? Colors.orange : Colors.green, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Analizando tus transacciones de este mes...',
                        style: TextStyle(fontSize: 16)),
                    const SizedBox(height: 16),
                    Text(
                      'Has gastado Q${deseosGasto.toStringAsFixed(0)} en "Deseos", lo que representa un ${porcentajeDeseos.toStringAsFixed(1)}% de tus ingresos.',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    sePaso
                        ? Text(
                        '⚠️ Te has pasado por un ${(porcentajeDeseos - 30).toStringAsFixed(1)}% del límite recomendado.',
                        style: TextStyle(
                            color: Colors.orange[900],
                            fontWeight: FontWeight.bold))
                        : Text(
                        '✅ ¡Excelente! Estás bajo el límite seguro del 30%.',
                        style: TextStyle(
                            color: Colors.green[900],
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                '¿Lograste mantenerte bajo el límite?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _checkAnswer(true), // Ambos avanzan
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('Sí, voy bien 👍'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _checkAnswer(true), // Ambos avanzan
                      style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: const Text('No, me pasé 😅'),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyStateEspejoReal() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.dashboard_customize_rounded, size: 80, color: Colors.blue[200]),
          const SizedBox(height: 24),
          const Text(
            '¡Activa tu auditoría en tiempo real!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Aún no tienes ingresos registrados este mes. Registra tus movimientos en tu Dashboard para que la app analice automáticamente tu regla 50/30/20.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          _buildComprobarButton(
            isActive: true,
            buttonText: 'CONTINUAR LECCIÓN',
            onPressed: () => _checkAnswer(true),
          )
        ],
      ),
    );
  }

  // 🎨 PANTALLA 4: Micro-Compromiso
  Widget _buildPantalla4Compromiso() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 COMPROMISO DE LA SEMANA',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Text(
            'Para equilibrar tu regla esta semana y evitar el gasto hormiga, ¿en qué categoría vas a recortar gastos?',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey[900]),
          ),
          const SizedBox(height: 24),
          _buildOptionCard(
              index: 0,
              text: '🍔 Comida Fuera (Fast Food)',
              isSelected: _selectedCommitmentOption == 0,
              onTap: () => setState(() => _selectedCommitmentOption = 0)),
          _buildOptionCard(
              index: 1,
              text: '🎬 Entretenimiento (Streaming/Cine)',
              isSelected: _selectedCommitmentOption == 1,
              onTap: () => setState(() => _selectedCommitmentOption = 1)),
          _buildOptionCard(
              index: 2,
              text: '🛍️ Ropa y Compras Varias',
              isSelected: _selectedCommitmentOption == 2,
              onTap: () => setState(() => _selectedCommitmentOption = 2)),
          const Spacer(),
          _buildComprobarButton(
            isActive: _selectedCommitmentOption != null,
            buttonText: 'FINALIZAR LECCIÓN 🎉',
            onPressed: () {
              // Limpiar y salir de forma exitosa
              Provider.of<LessonProvider>(context, listen: false).resetLesson();
              Navigator.pop(context);

              // Opcional: Mostrar un snackbar de felicitación
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Lección completada! Ganaste +10 Puntos Finavid.'),
                    backgroundColor: Colors.green,
                  )
              );
            },
          ),
        ],
      ),
    );
  }

  // Utilidad: Tarjeta de opción seleccionable
  Widget _buildOptionCard(
      {required int index,
        required String text,
        required bool isSelected,
        required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
          border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[300]!, width: 2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(text,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.blue[900] : Colors.black87)),
            ),
          ],
        ),
      ),
    );
  }

  // Utilidad: Botón de acción genérico
  Widget _buildComprobarButton(
      {required bool isActive, required VoidCallback onPressed, String buttonText = 'COMPROBAR'}) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isActive ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? Colors.blueAccent : Colors.grey[300],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: isActive ? 2 : 0,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}