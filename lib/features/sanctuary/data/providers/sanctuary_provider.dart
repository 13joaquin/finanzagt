// Archivo: lib/providers/sanctuary_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../goals/data/models/debt_model.dart';
import '../../../goals/data/models/goal_model.dart';

enum TreeStage { seed, sprout, youngTree, fullTree, blooming }
enum WeatherState { sunny, cloudy, rainy }

// --- Estado inmutable del Santuario ---
// Agrupa las tres piezas de estado que antes vivían como campos privados
// del ChangeNotifier, para poder exponerlas como un único `state` en Riverpod.
class SanctuaryState {
  final TreeStage treeStage;
  final WeatherState weatherState;
  final List<DebtModel> activeStones; // Obstáculos: deudas con saldo pendiente

  const SanctuaryState({
    this.treeStage = TreeStage.seed,
    this.weatherState = WeatherState.sunny,
    this.activeStones = const [],
  });

  SanctuaryState copyWith({
    TreeStage? treeStage,
    WeatherState? weatherState,
    List<DebtModel>? activeStones,
  }) {
    return SanctuaryState(
      treeStage: treeStage ?? this.treeStage,
      weatherState: weatherState ?? this.weatherState,
      activeStones: activeStones ?? this.activeStones,
    );
  }
}

final sanctuaryProvider = NotifierProvider<SanctuaryProvider, SanctuaryState>(
  SanctuaryProvider.new,
);

class SanctuaryProvider extends Notifier<SanctuaryState> {
  // Getters para la UI
  TreeStage get treeStage => state.treeStage;
  WeatherState get weatherState => state.weatherState;

  // Número de obstáculos activos.
  List<DebtModel> get activeStones => state.activeStones;
  int get stoneCount => state.activeStones.length;

  @override
  SanctuaryState build() {
    return const SanctuaryState();
  }

  // Actualiza el estado del Santuario con la información financiera.
  void updateFromProviders({
    required List<GoalModel> goals,
    required List<DebtModel> debts,
    required double totalIncomes,
    required double totalExpenses,
  }) {
    // 1. Calculamos las piedras primero para que la UI sepa qué dibujar
    final newStones = _calculateStones(debts);

    // 2. Mantenemos tu lógica intacta para el árbol y el clima
    final newTreeStage = _calculateTreeStage(goals, debts);
    final newWeatherState = _calculateWeather(totalIncomes, totalExpenses);

    state = state.copyWith(
      activeStones: newStones,
      treeStage: newTreeStage,
      weatherState: newWeatherState,
    );
  }

  // Identifica deudas activas como obstáculos
  List<DebtModel> _calculateStones(List<DebtModel> debts) {
    // Filtramos solo las deudas que tienen saldo pendiente[cite: 1, 8]
    return debts.where((d) => d.remainingAmount > 0).toList();
  }

  // Calcula la etapa de crecimiento del árbol.
  TreeStage _calculateTreeStage(List<GoalModel> goals, List<DebtModel> debts) {
    /*int*/ final totalItems = goals.length + debts.length;
    if (totalItems == 0) {
      return TreeStage.seed;
    }

    double totalProgress = 0;

    for (var goal in goals) {
      if (goal.targetAmount <= 0) continue;
      totalProgress += (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);
    }
    for (var debt in debts) {
      totalProgress += debt.paymentProgress;
    }

    /*double*/final averageProgress = totalProgress / totalItems;

    if (averageProgress < 0.15) {
      return TreeStage.seed;
    } else if (averageProgress < 0.40) {
      return TreeStage.sprout;
    } else if (averageProgress < 0.70) {
      return TreeStage.youngTree;
    } else if (averageProgress < 0.95) {
      return TreeStage.fullTree;
    } else {
      return TreeStage.blooming;
    }
  }

  // Calcula el clima del Santuario.
  WeatherState _calculateWeather(double income, double expenses) {
    if (income == 0) {
      return WeatherState.cloudy;
    }

    /*double*/ final expenseRatio = expenses / income;

    if (expenses > income) {
      return WeatherState.rainy;
    } else if (expenseRatio > 0.80) {
      return WeatherState.cloudy;
    } else {
      return WeatherState.sunny;
    }
  }

  String get weatherDescription {
    switch (state.weatherState) {
      case WeatherState.sunny: return "¡Excelente gestión! El sol brilla en tu santuario.";
      case WeatherState.cloudy: return "Cuidado, tus gastos están aumentando. Se ven nubes.";
      case WeatherState.rainy: return "¡Alerta! Estás gastando más de lo que recibes.";
    }
  }
}