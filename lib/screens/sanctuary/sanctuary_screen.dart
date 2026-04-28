// Archivo: lib/screens/sanctuary/sanctuary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../providers/user_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../../providers/GoalProvider.dart';      // Importamos los jefes de datos
import '../../providers/debt_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../data/models/goal_model.dart';
import '../../data/models/debt_model.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

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

    // 1. ESCUCHAMOS A LOS DUEÑOS DE LA INFORMACIÓN
    final goalProvider = Provider.of<GoalProvider>(context);
    final debtProvider = Provider.of<DebtProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final sanctuaryProvider = Provider.of<SanctuaryProvider>(context, listen: false);

    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F5E9),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 2. EL CABLEADO AUTOMÁTICO
    // Usamos addPostFrameCallback para actualizar el Santuario después de que se dibuje la pantalla
    // Así el clima y el árbol reaccionan a los datos reales de los otros Providers.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      sanctuaryProvider.updateFromProviders(
        goals: goalProvider.goals,
        debts: debtProvider.debts,
        totalIncomes: transactionProvider.totalIncomes,
        totalExpenses: transactionProvider.totalExpenses,
      );
    });

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: Consumer<SanctuaryProvider>(
        builder: (context, sanctuary, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: sanctuary.weatherState == WeatherState.rainy
                    ? [Colors.blueGrey.shade800, Colors.blueGrey.shade400]
                    : [const Color(0xFFE8F5E9), Colors.white],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    "Tu Santuario Financiero",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: sanctuary.weatherState == WeatherState.rainy ? Colors.white : Colors.green.shade900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Text(
                      sanctuary.weatherDescription,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: sanctuary.weatherState == WeatherState.rainy ? Colors.white70 : Colors.green.shade700,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // ÁREA DEL ÁRBOL (DISEÑO UI PRESERVADO)
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (sanctuary.weatherState == WeatherState.sunny)
                          const Icon(Icons.wb_sunny, size: 100, color: Colors.orangeAccent),
                        Icon(
                          Icons.eco,
                          size: 200,
                          color: sanctuary.weatherState == WeatherState.rainy ? Colors.green.shade200 : Colors.green.shade600,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _getStageDescription(sanctuary.treeStage),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),

                  // BOTONES DE PRUEBA (CORREGIDOS CON totalIncomes)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          sanctuary.updateFromProviders(
                              goals: [],
                              debts: [],
                              totalIncomes: 1000, // Arreglado
                              totalExpenses: 2000
                          );
                        },
                        child: const Text("Lluvia"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          sanctuary.updateFromProviders(
                              goals: [
                                GoalModel(id: '1', name: 'Prueba', targetAmount: 1000, currentAmount: 500, colorHex: '#4A47F6')
                              ],
                              debts: [],
                              totalIncomes: 5000, // Arreglado
                              totalExpenses: 500
                          );
                        },
                        child: const Text("Mitad"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {
                          sanctuary.updateFromProviders(
                              goals: [
                                GoalModel(id: '1', name: 'Éxito', targetAmount: 1000, currentAmount: 1000, colorHex: '#4A47F6')
                              ],
                              debts: [],
                              totalIncomes: 5000, // Arreglado
                              totalExpenses: 500
                          );
                        },
                        child: const Text("Meta"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}