import 'package:flutter/material.dart';
import 'package:finanzagt/data/models/lesson_model.dart';

const List<LessonModel> appLessonsRoute = [
  // --- NIVEL 1: FUNDAMENTOS ---
  LessonModel(
    id: 'lesson_01',
    title: 'Radiografía Financiera',
    description: 'Descubre adónde van tus Quetzales cada mes.',
    level: 'Nivel 1',
    icon: Icons.search_rounded, // Ícono agregado
    steps: [
      LessonStep(
        title: 'El primer paso',
        content: 'Para mejorar tus finanzas, primero debes saber exactamente en qué gastas. No se puede mejorar lo que no se mide.',
      ),
      LessonStep(
        title: 'Tu ingreso real',
        content: '¿Sabes cuánto dinero líquido te queda después de impuestos y deducciones de ley?',
        question: '¿Qué es el ingreso neto?',
        options: [
          'Mi salario base sin descuentos',
          'El dinero que realmente recibo en mi cuenta',
          'Mis ahorros totales'
        ],
        correctOptionIndex: 1,
      ),
    ],
  ),
  LessonModel(
    id: 'lesson_02',
    title: 'El Salvavidas (Fondo de Emergencia)',
    description: 'Tu escudo contra los imprevistos de la vida.',
    level: 'Nivel 1',
    icon: Icons.security_rounded, // Ícono agregado
    steps: [
      LessonStep(
        title: '¿Qué es el Fondo de Emergencia?',
        content: 'Es un dinero guardado exclusivamente para imprevistos: una emergencia médica, una reparación del carro o la pérdida de empleo.',
      ),
      LessonStep(
        title: 'Meta Inicial',
        content: 'No intentes ahorrar 6 meses de gastos de golpe. Empieza con una meta alcanzable: Q1,000 libres para urgencias.',
        question: '¿Para qué deberías usar tu fondo de emergencia?',
        options: [
          'Para el enganche de un teléfono nuevo',
          'Para unas vacaciones en Atitlán',
          'Para un gasto médico inesperado'
        ],
        correctOptionIndex: 2,
      ),
    ],
  ),
  LessonModel(
    id: 'lesson_03',
    title: 'La Regla 50/30/20',
    description: 'Equilibrio perfecto entre gastos, gustos y ahorro.',
    level: 'Nivel 1',
    icon: Icons.pie_chart_rounded, // Ícono agregado
    steps: [
      LessonStep(
        title: 'Divide y vencerás',
        content: 'Esta regla divide tus ingresos netos en tres grandes bloques: 50% Necesidades, 30% Deseos y 20% Ahorro o Inversión.',
      ),
    ],
  ),
  LessonModel(
    id: 'lesson_04',
    title: 'Compras Impulsivas',
    description: 'Evita el gasto emocional.',
    isPremium: false,
    level: 'Nivel 1',
    icon: Icons.shopping_cart_checkout_rounded,
    // Como no tiene 'steps' definidos, usará el [] por defecto gracias al fix anterior
  ),

  // --- NIVEL 2: CRECIMIENTO (PRO) ---
  LessonModel(
    id: 'lesson_05',
    title: 'Inflación de Estilo',
    description: 'Gana más, ahorra más.',
    isPremium: true,
    level: 'Nivel 2',
    icon: Icons.trending_up_rounded,
  ),
  LessonModel(
    id: 'lesson_06',
    title: 'Cero Deudas',
    description: 'Estrategias de salida.',
    isPremium: true,
    level: 'Nivel 2',
    icon: Icons.credit_score_rounded,
  ),
  LessonModel(
    id: 'lesson_07',
    title: 'Ahorro con Propósito',
    description: 'Construye patrimonio.',
    isPremium: true,
    level: 'Nivel 2',
    icon: Icons.account_balance_rounded,
  ),
];