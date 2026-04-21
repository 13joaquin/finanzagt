// Archivo: lib/providers/sanctuary_provider.dart
import 'package:flutter/material.dart';
import '../data/models/goal_model.dart';
import '../data/models/debt_model.dart';

// 1. Definimos los "Estados" posibles
enum TreeStage { seed, sprout, youngTree, fullTree, blooming }
enum WeatherState { sunny, cloudy, rainy }

class SanctuaryProvider extends ChangeNotifier {
  // Valores por defecto al iniciar
  TreeStage _treeStage = TreeStage.seed;
  WeatherState _weatherState = WeatherState.sunny;

  // Getters para que la pantalla pueda leer estos valores
  TreeStage get treeStage => _treeStage;
  WeatherState get weatherState => _weatherState;

  // 2. LA FUNCIÓN PRINCIPAL (El Gran Cableado)
  void updateFromProviders({
    required List<GoalModel> goals,
    required List<DebtModel> debts,
    required double totalExpenses,
  }) {
    // ¡Actualizado! Ahora le pasamos ambas listas al árbol
    _calculateTreeStage(goals, debts);
    _calculateWeather(debts, totalExpenses);

    // Le avisa a la pantalla visual que los cálculos cambiaron
    notifyListeners();
  }

  // 3. FÓRMULA DE VITALIDAD GLOBAL ACTUALIZADA (Metas + Deudas)
  void _calculateTreeStage(List<GoalModel> goals, List<DebtModel> debts) {
    int totalItems = goals.length + debts.length;

    // Si el usuario no tiene metas ni deudas registradas, el árbol es una semilla
    if (totalItems == 0) {
      _treeStage = TreeStage.seed;
      return;
    }

    double totalProgress = 0.0;

    // A) Sumamos el progreso de cada meta
    for (var goal in goals) {
      totalProgress += goal.progress;
    }

    // B) Sumamos el progreso de cada deuda (usando paymentProgress)
    for (var debt in debts) {
      totalProgress += debt.paymentProgress;
    }

    // C) Promedio Ponderado de Vitalidad (La suma de ambos mundos)
    double averageVitality = totalProgress / totalItems;

    // Evaluamos el crecimiento del árbol basándonos en la vitalidad conjunta
    if (averageVitality < 0.1) {
      _treeStage = TreeStage.seed;         // 0% - 10%
    } else if (averageVitality < 0.35) {
      _treeStage = TreeStage.sprout;       // 11% - 35%
    } else if (averageVitality < 0.70) {
      _treeStage = TreeStage.youngTree;    // 36% - 70%
    } else if (averageVitality < 0.99) {
      _treeStage = TreeStage.fullTree;     // 71% - 99%
    } else {
      _treeStage = TreeStage.blooming;     // 100% (¡Metas cumplidas y Deudas pagadas!)
    }
  }

  // 4. FÓRMULA DEL CLIMA (Adaptada a las deudas y gastos)
  void _calculateWeather(List<DebtModel> debts, double expenses) {
    bool hasPendingDebts = debts.any((d) => !d.isPaidThisMonth && d.remainingAmount > 0);

    if (hasPendingDebts) {
      _weatherState = WeatherState.cloudy; // Deudas sin abonar este mes = Nublado
    } else if (expenses > 0 && debts.isNotEmpty) {
      _weatherState = WeatherState.rainy;  // Gastos mientras hay deudas = Lluvia
    } else {
      _weatherState = WeatherState.sunny;  // Todo bajo control = Soleado
    }
  }
}