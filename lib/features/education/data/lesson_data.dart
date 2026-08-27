// Archivo: lib/data/lesson_data.dart
import 'package:flutter/material.dart';

import 'models/lesson_model.dart';

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
        title: 'Tu Punto de Partida',
        content: 'Antes de poder arreglar tus finanzas, necesitas saber dónde estás parado. Es como usar Waze: no puedes trazar una ruta si no sabes tu ubicación actual.',
      ),
      LessonStep(
        title: 'El Patrimonio Neto',
        content: 'El Patrimonio Neto es la fórmula mágica de la riqueza real. Es simple: Todo lo que TIENES (Activos) menos todo lo que DEBES (Pasivos).',
        question: 'Si tienes Q5,000 en el banco y debes Q2,000 en la tarjeta de crédito, ¿cuál es tu Patrimonio Neto?',
        options: [
          'Q7,000',
          'Q3,000',
          'Q5,000'
        ],
        correctOptionIndex: 1,
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
        content: 'Es un dinero guardado exclusivamente para imprevistos: una emergencia médica, una reparación del carro o la pérdida de empleo. No es para salir a cenar.',
      ),
      LessonStep(
        title: 'Meta Inicial',
        content: 'No intentes ahorrar 6 meses de gastos de golpe. Empieza con una meta alcanzable: Q1,000 a Q3,000 libres para urgencias básicas.',
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
        content: 'Si ganas Q4,000 al mes, tu límite máximo para "Deseos" (salidas, ropa, streaming) debería ser el 30%, es decir, Q1,200.',
        question: 'Si pagas la factura de luz (EEGSA/Energuate) de tu casa, ¿en qué porcentaje entra?',
        options: [
          '50% - Necesidades Básicas',
          '30% - Deseos y Gustos',
          '20% - Ahorro e Inversión'
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
        content: 'Antes de comprar algo que no necesitas urgentemente (ej. ropa nueva o pedir comida por app), aplica la regla de esperar 24 horas. Muchas veces el impulso desaparece.',
      ),
      LessonStep(
        title: 'El Gasto Hormiga',
        content: 'Ese cafecito diario de Q15 o el antojito en la tienda parece inofensivo, pero al mes representa Q450 menos en tu bolsa, ¡al año son Q5,400!',
        question: '¿Cuál es la mejor técnica contra las compras impulsivas?',
        options: [
          'Usar siempre la tarjeta de crédito a cuotas',
          'Esperar 24 horas antes de realizar la compra',
          'Gastar todo el primer día para no tener tentaciones'
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
        content: '¿Alguna vez te han subido el sueldo pero sigues sintiendo que no llegas a fin de mes? Eso es la Inflación de Estilo de Vida: tus gastos de "lujos" suben al mismo ritmo que tus ingresos.',
      ),
      LessonStep(
        title: 'La Solución: Congelar',
        content: 'Cuando recibas un aumento o un bono, asigna automáticamente el 50% de ese dinero extra a tus ahorros o inversiones antes de gastarlo en mejorar tu estilo de vida.',
        question: 'Si recibes un bono de Q1,000, ¿qué deberías hacer para evitar la inflación de estilo de vida?',
        options: [
          'Gastar los Q1,000 en un buen restaurante',
          'Guardar al menos Q500 (50%) en tu cuenta de ahorro',
          'Comprar algo a cuotas usando el bono como enganche'
        ],
        correctOptionIndex: 1,
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
        title: 'El Dinero Rojo vs Dinero Verde',
        content: 'El interés que pagas por deudas de consumo (tarjetas) destruye tu dinero. Una tarjeta de crédito en Guatemala puede cobrarte hasta un 60% anual si solo pagas el saldo mínimo.',
      ),
      LessonStep(
        title: 'El Efecto Bola de Nieve',
        content: 'Para salir rápido, ordena tus deudas de la más pequeña a la más grande. Paga el mínimo en todas, y abona todo el dinero extra posible a la deuda más pequeña hasta eliminarla.',
        question: 'En el método Bola de Nieve, ¿qué deuda atacas primero con tu dinero extra?',
        options: [
          'La deuda con la tasa de interés más alta',
          'La deuda con el saldo total más pequeño',
          'La deuda más grande y abrumadora'
        ],
        correctOptionIndex: 1,
      ),
    ],
  ),
  LessonModel(
    id: 'lesson_07',
    title: 'Metas con Propósito',
    description: 'Construye patrimonio a largo plazo.',
    isPremium: true,
    level: 'Nivel 2',
    icon: Icons.account_balance_rounded,
    steps: [
      LessonStep(
        title: 'Ahorrar vs Invertir',
        content: 'Ahorrar es proteger el dinero (para tu fondo de emergencia). Invertir es poner el dinero a trabajar para que genere más dinero, combatiendo la inflación.',
      ),
      LessonStep(
        title: 'El Poder del Propósito',
        content: 'Es difícil ahorrar "por ahorrar". Ponle nombre a tu dinero: "Enganche para mi Casa en 2028" o "Viaje a Europa". Un objetivo claro evita que te gastes ese fondo.',
        question: '¿Por qué es importante invertir tu dinero a largo plazo en lugar de solo guardarlo bajo el colchón?',
        options: [
          'Porque la inflación hace que el dinero pierda valor con el tiempo',
          'Para poder presumirle a tus amigos',
          'Porque los bancos te obligan a hacerlo'
        ],
        correctOptionIndex: 0,
      ),
    ],
  ),
];