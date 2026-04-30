// Archivo: lib/screens/sanctuary/sanctuary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../providers/user_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../../providers/GoalProvider.dart';
import '../../providers/debt_provider.dart';
import '../../providers/transaction_provider.dart';

class SanctuaryScreen extends StatefulWidget {
  const SanctuaryScreen({super.key});

  @override
  State<SanctuaryScreen> createState() => _SanctuaryScreenState();
}

class _SanctuaryScreenState extends State<SanctuaryScreen> with TickerProviderStateMixin {
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
    final userProvider = Provider.of<UserProvider>(context);
    final goalProvider = Provider.of<GoalProvider>(context);
    final debtProvider = Provider.of<DebtProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final sanctuaryProvider = Provider.of<SanctuaryProvider>(context, listen: false);

    if (userProvider.currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Sincronización con los datos reales del Jefe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sanctuaryProvider.updateFromProviders(
        goals: goalProvider.goals,
        debts: debtProvider.debts,
        // En tu sanctuary_provider actual, el método _calculateWeather solo pide expenses y debts,
        // pero lo dejamos preparado según la estructura que tengas.
        totalExpenses: transactionProvider.totalExpenses,
        totalIncomes: transactionProvider.totalIncomes,
      );
    });

    return Scaffold(
      body: Consumer<SanctuaryProvider>(
        builder: (context, sanctuary, child) {

          final targetProgress = _getTreeProgress(sanctuary.treeStage);
          if (_lastProgress != targetProgress) {
            _lastProgress = targetProgress;
            _treeController.animateTo(targetProgress, curve: Curves.easeInOut);
          }

          return Container(
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

                  // --- CAPA 2: CONTENIDO SCROLLABLE (Adiós Overflow) ---
                  // Aquí aplicamos el SingleChildScrollView
                  SingleChildScrollView(
                    physics: const BouncingScrollPhysics(), // Efecto de rebote suave
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
                            sanctuary.weatherDescription,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: sanctuary.weatherState == WeatherState.rainy ? Colors.white70 : Colors.green.shade700,
                            ),
                          ),
                        ),

                        // Reemplazamos los Spacer() por SizedBox fijos
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

                        const SizedBox(height: 40),

                        // TARJETA DE INFORMACIÓN
                        Container(
                          padding: const EdgeInsets.all(20),
                          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
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

                        // Este espacio extra abajo es crucial para que cuando agreguemos
                        // las macetas y deudas, la pantalla no se sienta cortada.
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}