// Archivo: lib/screens/sanctuary/sanctuary_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../../goals/data/providers/GoalProvider.dart';
import '../../../goals/data/providers/debt_provider.dart';
import '../../../transactions/data/providers/transaction_provider.dart';
import '../../data/providers/sanctuary_provider.dart';


class SanctuaryScreen extends ConsumerStatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  ConsumerState<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends ConsumerState<SanctuaryScreen> with TickerProviderStateMixin {
  late AnimationController _treeController;
  double _lastProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _treeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void dispose() {
    _treeController.dispose();
    super.dispose();
  }

  double _getTreeProgress(TreeStage stage) {
    switch (stage) {
      case TreeStage.seed: return 0.05;
      case TreeStage.sprout: return 0.25;
      case TreeStage.youngTree: return 0.50;
      case TreeStage.fullTree: return 0.80;
      case TreeStage.blooming: return 1.0;
    }
  }

  String _getStageDescription(TreeStage stage) {
    switch (stage) {
      case TreeStage.seed: return "Una semilla esperando crecer...";
      case TreeStage.sprout: return "¡Un pequeño brote! Vas por buen camino.";
      case TreeStage.youngTree: return "Tu árbol joven se está fortaleciendo.";
      case TreeStage.fullTree: return "Un árbol fuerte y frondoso.";
      case TreeStage.blooming: return "¡Floreciendo! Has cumplido tus metas.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(userProvider);
    final goals = ref.watch(goalProvider);
    final debts = ref.watch(debtProvider);
    // Escucha cambios en las transacciones para mantener sincronizado el Santuario.
    ref.watch(transactionProvider);
    final txNotifier = ref.read(transactionProvider.notifier);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Sincronización con los datos reales del Jefe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sanctuaryProvider.notifier).updateFromProviders(
        goals: goals,
        debts: debts,
        totalExpenses: txNotifier.totalExpenses,
        totalIncomes: txNotifier.totalIncomes,
      );
    });

    final sanctuary = ref.watch(sanctuaryProvider);
    final sanctuaryNotifier = ref.read(sanctuaryProvider.notifier);

    final targetProgress = _getTreeProgress(sanctuary.treeStage);
    if (_lastProgress != targetProgress) {
      _lastProgress = targetProgress;
      _treeController.animateTo(targetProgress, curve: Curves.easeInOut);
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: sanctuary.weatherState == WeatherState.rainy
                ? [Colors.blueGrey.shade900, Colors.blueGrey.shade600]
                : sanctuary.weatherState == WeatherState.cloudy
                ? [Colors.blueGrey.shade300, Colors.blue.shade100]
                : [const Color(0xFFE8F5E9), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // --- CAPA 1: CLIMA (Fondo fijo) ---
              if (sanctuary.weatherState == WeatherState.rainy)
                Positioned.fill(
                  child: Lottie.asset('assets/animations/rain.json', fit: BoxFit.cover),
                ),

              if (sanctuary.weatherState == WeatherState.sunny)
                Positioned(
                  top: 20,
                  right: 20,
                  child: Lottie.asset('assets/animations/little_sun.json', height: 180),
                ),

              if (sanctuary.weatherState == WeatherState.cloudy)
                Positioned(
                  top: 40,
                  left: 0,
                  right: 0,
                  child: Lottie.asset('assets/animations/weather.json', height: 150),
                ),

              // --- CAPA 2: CONTENIDO SCROLLABLE ---
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Text(
                      "Tu Santuario Financiero",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: sanctuary.weatherState == WeatherState.rainy ? Colors.white : Colors.green.shade900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        sanctuaryNotifier.weatherDescription,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: sanctuary.weatherState == WeatherState.rainy ? Colors.white70 : Colors.green.shade700,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // EL ÁRBOL
                    Center(
                      child: Lottie.asset(
                        'assets/animations/tree_growth_without_background.json',
                        controller: _treeController,
                        height: 450,
                        fit: BoxFit.contain,
                      ),
                    ),

                    // --- CAPA 3: LAS PIEDRAS (DEUDAS / OBSTÁCULOS) ---
                    // Solo se dibuja si hay piedras activas calculadas en el provider
                    if (sanctuary.activeStones.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 20, // Espacio horizontal entre piedras
                          runSpacing: 15, // Espacio vertical si hay muchas piedras
                          children: sanctuary.activeStones.map((stone) {
                            // Calculamos un tamaño base para simular el "peso" de la deuda
                            /*double*/ final baseSize = stone.totalAmount > 5000 ? 70.0 : 50.0;
                            // Mientras más se paga, más transparente se vuelve la piedra
                            /*double*/final stoneOpacity = 1.0 - (stone.paymentProgress * 0.7);

                            return Tooltip(
                              message: '${stone.name}\nFalta: Q${stone.remainingAmount.toStringAsFixed(2)}',
                              child: Icon(
                                Icons.terrain, // Puedes cambiar esto por un Image.asset o Lottie después
                                size: baseSize,
                                color: Colors.blueGrey.shade800.withValues(alpha: stoneOpacity),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 40),

                    // TARJETA DE INFORMACIÓN
                    Container(
                      padding: const EdgeInsets.all(20),
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _getStageDescription(sanctuary.treeStage),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}