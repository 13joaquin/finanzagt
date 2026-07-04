// Archivo: lib/screens/education/education_screen.dart
import 'package:flutter/material.dart';

// Importa tus pantallas de lecciones
import 'lesson/lesson_50_30_20_screen.dart';
import 'lesson/emergency_fund_edu_screen.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  // 🛠️ INTERRUPTOR PRO (Para desarrollo/pruebas)
  // En producción, esto se leerá de un Provider (ej. Provider.of<SubscriptionProvider>(context).isPro)
  bool _isPro = false;

  void _showProPaywallBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 36),
                const SizedBox(width: 12),
                Text(
                  'Finavid PRO',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Desbloquea el Nivel 2 y toma el control total de tus finanzas. Aprende estrategias avanzadas para combatir la inflación y multiplicar tus Quetzales.',
              style: TextStyle(fontSize: 16, color: Colors.black87, height: 1.5),
            ),
            const SizedBox(height: 24),
            // Beneficios
            _buildProBenefit(Icons.check_circle_rounded, 'Acceso ilimitado a todas las lecciones.'),
            _buildProBenefit(Icons.check_circle_rounded, 'Análisis profundo de transacciones.'),
            _buildProBenefit(Icons.check_circle_rounded, 'Soporte prioritario.'),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // Aquí iría la lógica para llamar a RevenueCat
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Llamando a pasarela de pago...')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A47F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
                  'CONVERTIRME EN PRO - Q25/mes',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Quizás más tarde', style: TextStyle(color: Colors.grey[600])),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildProBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          // INTERRUPTOR PRO VISUAL
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  _isPro ? 'Modo PRO' : 'Modo Gratis',
                  style: TextStyle(
                    color: _isPro ? Colors.amber[800] : Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Switch(
                  value: _isPro,
                  activeColor: Colors.amber,
                  onChanged: (val) {
                    setState(() {
                      _isPro = val;
                    });
                  },
                ),
              ],
            ),
          )
        ],
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
                    color: _isPro
                        ? Colors.amber.withOpacity(0.1)
                        : const Color(0xFF4A47F6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(
                      _isPro ? Icons.workspace_premium_rounded : Icons.school_rounded,
                      color: _isPro ? Colors.amber[800] : const Color(0xFF4A47F6),
                      size: 32
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isPro ? 'Academia PRO' : 'Academia Finavid',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
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

            // --- MÓDULO 1: FUNDAMENTOS (Siempre Gratis) ---
            _buildSectionTitle('Nivel 1: Fundamentos', Icons.foundation),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'El Escudo Financiero',
              description: 'Aprende qué es el fondo de emergencia y por qué te da paz mental.',
              icon: Icons.security_rounded,
              color: const Color(0xFF1976D2),
              isLocked: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EmergencyFundEduScreen()));
              },
            ),

            _buildLessonCard(
              context: context,
              title: 'La Regla 50/30/20',
              description: 'El mapa más sencillo para distribuir tu salario sin estrés.',
              icon: Icons.pie_chart_rounded,
              color: const Color(0xFFE64A19),
              isLocked: false,
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Lesson503020Screen()));
              },
            ),

            const SizedBox(height: 30),

            // --- MÓDULO 2: CRECIMIENTO (Requiere PRO) ---
            _buildSectionTitle('Nivel 2: Crecimiento', Icons.trending_up_rounded),
            const SizedBox(height: 15),

            _buildLessonCard(
              context: context,
              title: 'Inflación de Estilo de Vida',
              description: 'Ganas más, pero el dinero no alcanza. ¿Por qué ocurre esto?',
              icon: Icons.shopping_bag_rounded,
              color: const Color(0xFF43A047), // Verde (Se muestra gris si está bloqueado)
              isPremiumLesson: true, // Marcamos que es premium
              isLocked: !_isPro, // Si NO es pro, está bloqueada
              onTap: () {
                if (!_isPro) {
                  _showProPaywallBottomSheet();
                } else {
                  // Navigator.push(...) a la lección avanzada
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Abriendo lección avanzada...')),
                  );
                }
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA TÍTULOS DE SECCIÓN ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blueGrey[800], size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey[800]),
        ),
      ],
    );
  }

  // --- WIDGET PARA TARJETAS DE LECCIÓN ---
  Widget _buildLessonCard({
    required BuildContext context,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required bool isLocked,
    bool isPremiumLesson = false,
    required VoidCallback onTap,
  }) {
    // Si está bloqueada, forzamos tonos grises
    final Color appliedColor = isLocked ? Colors.grey : color;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
            color: isLocked ? Colors.transparent : appliedColor.withOpacity(0.3),
            width: 1.5
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Ícono de la lección
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: isLocked ? Colors.grey[100] : appliedColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      isLocked ? Icons.lock_rounded : icon,
                      color: isLocked ? Colors.grey[400] : appliedColor,
                      size: 30
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
                              title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isLocked ? Colors.grey[600] : Colors.blueGrey[900],
                              ),
                            ),
                          ),
                          if (isPremiumLesson && !_isPro)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'PRO',
                                style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        description,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Botón Play o Candado[cite: 11]
                Icon(
                  isLocked ? Icons.lock_outline : Icons.play_circle_fill_rounded,
                  color: isLocked ? Colors.grey[300] : appliedColor,
                  size: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}