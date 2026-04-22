// Archivo: lib/screens/sanctuary/sanctuary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../providers/user_provider.dart';
import '../../providers/sanctuary_provider.dart';
import '../../data/models/goal_model.dart'; // <--- NUEVO IMPORT
import '../../data/models/debt_model.dart'; // <--- NUEVO IMPORT

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

  String _getStageDescription(TreeStage stage) {
    switch (stage) {
      case TreeStage.seed:
        return "Una semilla esperando crecer...";
      case TreeStage.sprout:
        return "¡Un pequeño brote! Vas por buen camino.";
      case TreeStage.youngTree:
        return "Tu árbol joven se está fortaleciendo.";
      case TreeStage.fullTree:
        return "Un árbol fuerte y frondoso.";
      case TreeStage.blooming:
        return "¡Floreciendo! Has cumplido tus metas.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F5E9),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mi Santuario", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<SanctuaryProvider>(
        builder: (context, sanctuary, child) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE8F5E9), Colors.white],
              ),
            ),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    _getStageDescription(sanctuary.treeStage),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.green[800]),
                  ),

                  // Visualización del Árbol (Simulada por ahora con Icono o Lottie)
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Icon(
                        Icons.eco,
                        size: 150,
                        color: sanctuary.treeStage == TreeStage.blooming ? Colors.pink : Colors.green,
                      ),
                    ),
                  ),

                  // ESTADO DEL CLIMA
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          sanctuary.weatherState == WeatherState.sunny
                              ? Icons.wb_sunny : sanctuary.weatherState == WeatherState.cloudy
                              ? Icons.cloud : Icons.umbrella,
                          color: Colors.orange,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Clima: ${sanctuary.weatherState.name.toUpperCase()}",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // BOTONES DE SIMULACIÓN (CORREGIDOS)
                  const Text("Panel de Pruebas (Debug):", style: TextStyle(color: Colors.grey)),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Simulación: Sin metas = Semilla
                          sanctuary.updateFromProviders(
                              goals: [],
                              debts: [],
                              totalExpenses: 0
                          );
                        },
                        child: const Text("Semilla"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Simulación: Una meta al 50%
                          sanctuary.updateFromProviders(
                              goals: [
                                GoalModel(id: '1', name: 'Prueba', targetAmount: 1000, currentAmount: 500, colorHex: '#4A47F6')
                              ],
                              debts: [],
                              totalExpenses: 500
                          );
                        },
                        child: const Text("Mitad"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Simulación: Meta cumplida al 100%
                          sanctuary.updateFromProviders(
                              goals: [
                                GoalModel(id: '1', name: 'Éxito', targetAmount: 1000, currentAmount: 1000, colorHex: '#4A47F6')
                              ],
                              debts: [],
                              totalExpenses: 500
                          );
                        },
                        child: const Text("Meta Cumplida"),
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