// lib/data/models/debt_model.dart

class DebtModel {
  final String id;
  final String name;
  final double totalAmount;    // El total de la deuda (ej. 5000)
  final double remainingAmount; // Lo que falta pagar (ej. 2000)
  final DateTime dueDate;      // Cuándo hay que pagar
  final bool isPaidThisMonth;  // ¿Ya hizo el pago de este mes?

  DebtModel({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.remainingAmount,
    required this.dueDate,
    this.isPaidThisMonth = false,
  });

  // Esta pequeña función ayuda al Santuario a saber el porcentaje de victoria
  double get paymentProgress {
    if (totalAmount <= 0) return 0.0;
    return (totalAmount - remainingAmount) / totalAmount;
  }
}