// Archivo: lib/data/models/lesson_model.dart
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
  final String level;         // Nivel de la lección
  final IconData icon;        // Ícono representativo
  final List<LessonStep> steps;

  const LessonModel({
    required this.id,
    required this.title,
    required this.description,
    this.isPremium = false,
    required this.level,
    required this.icon,
    this.steps = const [],    // Valor por defecto vacío
  });
}