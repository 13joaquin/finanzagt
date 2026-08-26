// Archivo: lib/providers/sanctuary_provider.dart
import 'package:flutter/material.dart';
import '../../../goals/data/models/goal_model.dart';
import '../../../goals/data/models/debt_model.dart';

enum TreeStage { seed, sprout, youngTree, fullTree, blooming }
enum WeatherState { sunny, cloudy, rainy }

class SanctuaryProvider extends ChangeNotifier {
  TreeStage _treeStage = TreeStage.seed;
  WeatherState _weatherState = WeatherState.sunny;

  // --- NUEVA PROPIEDAD PARA LAS PIEDRAS ---
  // Almacena las deudas que aún tienen saldo pendiente[cite: 1, 8]
  List<DebtModel> _activeStones = [];

  // Getters para la UI
  TreeStage get treeStage => _treeStage;
  WeatherState get weatherState => _weatherState;

  // NUEVO GETTER: Manda la señal de cuántas piedras dibujar
  List<DebtModel> get activeStones => _activeStones;
  int get stoneCount => _activeStones.length;

  // --- EL GRAN CABLEADO (ACTUALIZADO) ---
  void updateFromProviders({
    required List<GoalModel> goals,
    required List<DebtModel> debts,
    required double totalIncomes,
    required double totalExpenses,
  }) {
    // 1. Calculamos las piedras primero para que la UI sepa qué dibujar
    _calculateStones(debts);

    // 2. Mantenemos tu lógica intacta para el árbol y el clima
    _calculateTreeStage(goals, debts);
    _calculateWeather(totalIncomes, totalExpenses);

    notifyListeners();
  }

  // NUEVA FUNCIÓN: Identifica deudas activas como obstáculos
  void _calculateStones(List<DebtModel> debts) {
    // Filtramos solo las deudas que tienen saldo pendiente[cite: 1, 8]
    _activeStones = debts.where((d) => d.remainingAmount > 0).toList();
  }

  // 2. LÓGICA DEL ÁRBOL (VITALIDAD) - SE MANTIENE IGUAL
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
      totalProgress += debt.paymentProgress;
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

  // 3. LÓGICA DEL CLIMA - SE MANTIENE IGUAL[cite: 8]
  void _calculateWeather(double income, double expenses) {
    if (income == 0) {
      _weatherState = WeatherState.cloudy;
      return;
    }

    double expenseRatio = expenses / income;

    if (expenses > income) {
      _weatherState = WeatherState.rainy;
    } else if (expenseRatio > 0.80) {
      _weatherState = WeatherState.cloudy;
    } else {
      _weatherState = WeatherState.sunny;
    }
  }

  String get weatherDescription {
    switch (_weatherState) {
      case WeatherState.sunny: return "¡Excelente gestión! El sol brilla en tu santuario.";
      case WeatherState.cloudy: return "Cuidado, tus gastos están aumentando. Se ven nubes.";
      case WeatherState.rainy: return "¡Alerta! Estás gastando más de lo que recibes.";
    }
  }
}