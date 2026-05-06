// Archivo: lib/widgets/budget_card.dart
import 'package:flutter/material.dart';

class BudgetCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double spent;
  final double total;
  final IconData icon;
  final Color color;
  final String actionLabel;
  final VoidCallback onTap;

  const BudgetCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.spent,
    required this.total,
    required this.icon,
    required this.color,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- LÓGICA MATEMÁTICA BLINDADA ---
    double progress = 0.0;

    if (total > 0) {
      // Si hay un presupuesto válido, calculamos el porcentaje normalmente
      progress = (spent / total).clamp(0.0, 1.0);
    } else if (spent > 0) {
      // Si el límite es 0 (ej. no hay ingresos registrados) pero ya gastaste dinero,
      // la barra se llena al 100% para alertar que estás en números rojos.
      progress = 1.0;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.1),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Q${spent.toStringAsFixed(2)}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                'de Q${total.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 15),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onTap,
              child: Text(
                actionLabel,
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}