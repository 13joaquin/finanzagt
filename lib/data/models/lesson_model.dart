import 'package:flutter/material.dart';

class LessonStep {
  final String title;
  final String content;
  final String? question;
  final List<String>? options;
  final int? correctOptionIndex;

  const LessonStep({
    required this.title,
    required this.content,
    this.question,
    this.options,
    this.correctOptionIndex,
  });
}

class LessonModel {
  final String id;
  final String title;
  final String description;
  final bool isPremium;
  final String level;         // Agregado: Nivel de la lección
  final IconData icon;        // Agregado: Ícono representativo
  final List<LessonStep> steps;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    this.isPremium = false,
    required this.level,
    required this.icon,
    this.steps = const [],    // Solución al error: valor por defecto vacío
  });
}

// Data estática de los 7 cursos para evitar lecturas de Firestore
const List<LessonModel> appLessonsRoute = [
  LessonModel(id: 'lesson_01', title: 'Escudo Financiero', description: 'Tu fondo de emergencia.', isPremium: false, level: 'Nivel 1', icon: Icons.security_rounded),
  LessonModel(id: 'lesson_02', title: 'Regla 50/30/20', description: 'El mapa de tus ingresos.', isPremium: false, level: 'Nivel 1', icon: Icons.pie_chart_rounded),
  LessonModel(id: 'lesson_03', title: 'Gastos Superfluos', description: 'Detecta y frena fugas.', isPremium: false, level: 'Nivel 1', icon: Icons.money_off_rounded),
  LessonModel(id: 'lesson_04', title: 'Compras Impulsivas', description: 'Evita el gasto emocional.', isPremium: false, level: 'Nivel 1', icon: Icons.shopping_cart_checkout_rounded),
  LessonModel(id: 'lesson_05', title: 'Inflación de Estilo', description: 'Gana más, ahorra más.', isPremium: true, level: 'Nivel 2', icon: Icons.trending_up_rounded),
  LessonModel(id: 'lesson_06', title: 'Cero Deudas', description: 'Estrategias de salida.', isPremium: true, level: 'Nivel 2', icon: Icons.credit_score_rounded),
  LessonModel(id: 'lesson_07', title: 'Ahorro con Propósito', description: 'Construye patrimonio.', isPremium: true, level: 'Nivel 2', icon: Icons.account_balance_rounded),
];