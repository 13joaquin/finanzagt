// Archivo: lib/providers/sanctuary_provider.dart
import 'package:flutter/material.dart';
import '../data/models/goal_model.dart';
import '../data/models/debt_model.dart';

// 1. Estados Visuales del Santuario
enum TreeStage { seed, sprout, youngTree, fullTree, blooming }
enum WeatherState { sunny, cloudy, rainy }

class SanctuaryProvider extends ChangeNotifier {
  TreeStage _treeStage = TreeStage.seed;
  WeatherState _weatherState = WeatherState.sunny;

  // Getters para la UI
  TreeStage get treeStage => _treeStage;
  WeatherState get weatherState => _weatherState;

  // --- EL GRAN CABLEADO (PASO 2) ---
  // Esta función ahora recibe la información del TransactionProvider
  void updateFromProviders({
    required List<GoalModel> goals,
    required List<DebtModel> debts,
    required double totalIncomes,
    required double totalExpenses,
  }) {
    _calculateTreeStage(goals, debts);
    _calculateWeather(totalIncomes, totalExpenses);

    // Notificamos a la pantalla del Santuario para que cambie el clima o el árbol
    notifyListeners();
  }

  // 2. LÓGICA DEL ÁRBOL (VITALIDAD)
  // El árbol crece según completas metas y pagas deudas
  void _calculateTreeStage(List<GoalModel> goals, List<DebtModel> debts) {
    int totalItems = goals.length + debts.length;
    if (totalItems == 0) {
      _treeStage = TreeStage.seed;
      return;
    }

    double totalProgress = 0;
    for (var goal in goals) {
      totalProgress += (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    }
    for (var debt in debts) {
      totalProgress += (debt.paymentProgress / debt.totalAmount).clamp(0.0, 1.0);
    }

    double averageProgress = totalProgress / totalItems;

    if (averageProgress < 0.15) {
      _treeStage = TreeStage.seed;
    } else if (averageProgress < 0.40) {
      _treeStage = TreeStage.sprout;
    } else if (averageProgress < 0.70) {
      _treeStage = TreeStage.youngTree;
    } else if (averageProgress < 0.95) {
      _treeStage = TreeStage.fullTree;
    } else {
      _treeStage = TreeStage.blooming;
    }
  }

  // 3. LÓGICA DEL CLIMA (SALUD FINANCIERA)
  // ¡Aquí es donde el TransactionProvider toma el control!
  void _calculateWeather(double income, double expenses) {
    if (income == 0) {
      _weatherState = WeatherState.cloudy; // Sin ingresos el cielo se nubla
      return;
    }

    // Calculamos qué porcentaje del ingreso se está gastando
    double expenseRatio = expenses / income;

    if (expenses > income) {
      // Gastas más de lo que ganas: TORMENTA
      _weatherState = WeatherState.rainy;
    } else if (expenseRatio > 0.80) {
      // Gastas más del 80%: MUY NUBLADO (Advertencia)
      _weatherState = WeatherState.cloudy;
    } else {
      // Gastos controlados: SOL RADIANTE
      _weatherState = WeatherState.sunny;
    }
  }

  // Helpers para la UI (Textos dinámicos)
  String get weatherDescription {
    switch (_weatherState) {
      case WeatherState.sunny: return "¡Excelente gestión! El sol brilla en tu santuario.";
      case WeatherState.cloudy: return "Cuidado, tus gastos están aumentando. Se ven nubes.";
      case WeatherState.rainy: return "¡Alerta! Estás gastando más de lo que recibes.";
    }
  }
}