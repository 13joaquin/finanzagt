// Archivo: lib/providers/sanctuary_provider.dart
import 'package:flutter/material.dart';

// 1. Definimos los "Estados" posibles para que sea fácil leer el código
enum TreeStage { seed, sprout, youngTree, fullTree, blooming }
enum WeatherState { sunny, cloudy, rainy }

class SanctuaryProvider extends ChangeNotifier {
  // Valores por defecto al iniciar
  TreeStage _treeStage = TreeStage.seed;
  WeatherState _weatherState = WeatherState.sunny;

  // Getters para que la pantalla pueda leer estos valores
  TreeStage get treeStage => _treeStage;
  WeatherState get weatherState => _weatherState;

  // 2. LA FUNCIÓN PRINCIPAL: Actualiza todo el ecosistema
  // Esta función la llamaremos cada vez que el usuario agregue un gasto o un ahorro
  void updateSanctuary({
    required List<Map<String, dynamic>> activeGoals, // Lista de metas
    required double totalIncome,                     // Ingresos del mes
    required double totalExpenses,                   // Gastos del mes
  }) {
    _calculateTreeStage(activeGoals);
    _calculateWeather(totalIncome, totalExpenses);

    // Le avisa a la pantalla que los cálculos cambiaron para que se redibuje
    notifyListeners();
  }

  // 3. FÓRMULA DE VITALIDAD GLOBAL (El Árbol)
  void _calculateTreeStage(List<Map<String, dynamic>> goals) {
    if (goals.isEmpty) {
      _treeStage = TreeStage.seed;
      return;
    }

    double totalProgress = 0.0;

    // Sumamos el progreso de cada meta
    for (var goal in goals) {
      double saved = goal['saved'] ?? 0.0;
      double target = goal['target'] ?? 1.0; // Para evitar división por 0

      double progress = saved / target;
      if (progress > 1.0) progress = 1.0; // Tope máximo de 100%

      totalProgress += progress;
    }

    // Promedio Ponderado de Vitalidad
    double averageVitality = totalProgress / goals.length;

    // Asignamos la etapa según el porcentaje
    if (averageVitality < 0.1) {
      _treeStage = TreeStage.seed;         // 0% - 10%
    } else if (averageVitality < 0.35) {
      _treeStage = TreeStage.sprout;       // 11% - 35%
    } else if (averageVitality < 0.70) {
      _treeStage = TreeStage.youngTree;    // 36% - 70%
    } else if (averageVitality < 0.99) {
      _treeStage = TreeStage.fullTree;     // 71% - 99%
    } else {
      _treeStage = TreeStage.blooming;     // 100% (¡Meta cumplida!)
    }
  }

  // 4. FÓRMULA DEL CLIMA (Salud Financiera Mensual)
  void _calculateWeather(double income, double expenses) {
    // Si no hay ingresos pero sí hay gastos -> Tormenta automática
    if (income == 0 && expenses > 0) {
      _weatherState = WeatherState.rainy;
      return;
    }
    // Si la cuenta está en cero sin movimientos -> Día soleado por defecto
    else if (income == 0 && expenses == 0) {
      _weatherState = WeatherState.sunny;
      return;
    }

    // Índice de Salud Mensual
    double surplusMargin = 1 - (expenses / income);

    if (surplusMargin > 0.2) {
      _weatherState = WeatherState.sunny;  // Ahorra más del 20% (Bonanza)
    } else if (surplusMargin >= 0.0) {
      _weatherState = WeatherState.cloudy; // Vive al día (Alerta gris)
    } else {
      _weatherState = WeatherState.rainy;  // Gasta más de lo que gana (Crisis)
    }
  }
}