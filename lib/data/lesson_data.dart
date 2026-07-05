import 'package:flutter/material.dart';
import 'package:finanzagt/data/models/lesson_model.dart';

const List<LessonModel> appLessonsRoute = [
  // --- NIVEL 1: FUNDAMENTOS (Gratis) ---
  LessonModel(
    id: 'lesson_01',
    title: 'Radiografía Financiera',
    description: 'Descubre adónde van tus Quetzales cada mes.',
    level: 'Nivel 1',
    icon: Icons.search_rounded,
    steps: [
      LessonStep(
        title: 'El primer paso',
        content: 'Para mejorar tus finanzas, primero debes saber exactamente en qué gastas. No se puede mejorar lo que no se mide.',
      ),
      LessonStep(
        title: 'Tu ingreso real',
        content: '¿Sabes cuánto dinero líquido te queda después de impuestos y deducciones de ley como el IGSS?',
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
    icon: Icons.security_rounded,
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
    icon: Icons.pie_chart_rounded,
    steps: [
      LessonStep(
        title: 'Divide y vencerás',
        content: 'Esta regla divide tus ingresos en tres bloques: 50% Necesidades Básicas, 30% Deseos/Ocio y 20% Ahorro e Inversión.',
      ),
      LessonStep(
        title: 'El Límite del 30%',
        content: 'Si ganas Q4,000 al mes, tu límite máximo para "Deseos" (salidas, ropa, streaming) debería ser Q1,200.',
        question: 'Si pagas la factura de luz de tu casa, ¿en qué porcentaje entra?',
        options: [
          '50% - Necesidades',
          '30% - Deseos',
          '20% - Ahorro'
        ],
        correctOptionIndex: 0,
      ),
    ],
  ),
  LessonModel(
    id: 'lesson_04',
    title: 'Compras Impulsivas',
    description: 'Evita el gasto emocional y las fugas.',
    level: 'Nivel 1',
    icon: Icons.shopping_cart_checkout_rounded,
    steps: [
      LessonStep(
        title: 'La Fricción Positiva',
        content: 'Antes de comprar algo que no necesitas urgentemente (ej. una camisa nueva o pedir comida rápida), aplica la regla de las 24 horas.',
      ),
      LessonStep(
        title: 'El Gasto Hormiga',
        content: 'Ese cafecito diario de Q15 o la golosina en la tienda parece inofensivo, pero al mes representa Q450 menos en tu bolsa.',
        question: '¿Cuál es la mejor técnica contra las compras impulsivas?',
        options: [
          'Comprar con tarjeta de crédito',
          'Esperar 24 horas antes de comprar',
          'No llevar efectivo nunca'
        ],
        correctOptionIndex: 1,
      ),
    ],
  ),

  // --- NIVEL 2: CRECIMIENTO (PRO) ---
  LessonModel(
    id: 'lesson_05',
    title: 'Inflación de Estilo',
    description: 'Gana más, ahorra más.',
    isPremium: true,
    level: 'Nivel 2',
    icon: Icons.trending_up_rounded,
    steps: [
      LessonStep(
        title: 'El Síndrome del Bolsillo Roto',
        content: 'Cuando recibes un aumento de sueldo, es tentador empezar a gastar más en lujos. Esto se llama "Inflación de Estilo de Vida" y te mantiene atascado financieramente.',
      ),
    ],
  ),
  LessonModel(
    id: 'lesson_06',
    title: 'Cero Deudas',
    description: 'Estrategias de salida para tarjetas.',
    isPremium: true,
    level: 'Nivel 2',
    icon: Icons.credit_score_rounded,
    steps: [
      LessonStep(
        title: 'El Efecto Bola de Nieve',
        content: 'Para salir de deudas, ordena tus saldos del más pequeño al más grande. Paga el mínimo en todas, y abona todo el dinero extra posible a la deuda más pequeña hasta eliminarla.',
      ),
    ],
  ),
  LessonModel(
    id: 'lesson_07',
    title: 'Ahorro con Propósito',
    description: 'Construye patrimonio a largo plazo.',
    isPremium: true,
    level: 'Nivel 2',
    icon: Icons.account_balance_rounded,
    steps: [
      LessonStep(
        title: 'La Magia del Interés Compuesto',
        content: 'Tu dinero debe trabajar para ti. Al invertir tus ahorros, generas rendimientos, y esos rendimientos generan aún más dinero con el tiempo.',
      ),
    ],
  ),
];