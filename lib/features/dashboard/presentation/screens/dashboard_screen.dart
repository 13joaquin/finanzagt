// Archivo: lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';
import '../../../goals/data/providers/GoalProvider.dart';
import '../../../goals/data/providers/debt_provider.dart';
import '../../../sanctuary/data/providers/sanctuary_provider.dart';
import '../../../transactions/data/providers/transaction_provider.dart';


class MainDashboardScreen extends ConsumerStatefulWidget {
  const MainDashboardScreen({super.key});

  @override
  ConsumerState<MainDashboardScreen> createState() =>
      _MainDashboardScreenState();
}

class _MainDashboardScreenState extends ConsumerState<MainDashboardScreen> {
  final NumberFormat currencyFormat = NumberFormat('#,##0.00', 'en_US');

  @override
  Widget build(BuildContext context) {
    // 1. ESCUCHAMOS LOS PROVIDERS
    final currentUser = ref.watch(userProvider);
    final userNotifier = ref.read(userProvider.notifier);

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 1.5 ESCUCHAMOS A TODOS LOS MOTORES
    ref.watch(transactionProvider);
    ref.watch(goalProvider);
    ref.watch(debtProvider);
    final transactionNotifier = ref.read(transactionProvider.notifier);
    final goalNotifier = ref.read(goalProvider.notifier);
    final debtNotifier = ref.read(debtProvider.notifier);

    // ðŸŒŸ EL PUENTE DE SINCRONIZACIÃ“N: Avisamos al Santuario ðŸŒŸ
    // Usamos addPostFrameCallback para evitar errores de redibujado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(sanctuaryProvider.notifier).updateFromProviders(
        goals: goalNotifier.goals,
        debts: debtNotifier.debts,
        totalIncomes: transactionNotifier.totalIncomes,
        totalExpenses: transactionNotifier.totalExpenses,
      );
    });

    // 2. CÃLCULOS EN TIEMPO REAL (Usando el nuevo cerebro)
    double income = transactionNotifier.totalIncomes;
    double totalExpenses = transactionNotifier.totalExpenses;
    double netWorth = transactionNotifier.netWorth;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(userNotifier),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TARJETA DE PATRIMONIO NETO
            _buildNetWorthCard(netWorth),
            const SizedBox(height: 25),

            // FILA DE RESUMEN (INGRESOS VS GASTOS)
            Row(
              children: [
                Expanded(child: _buildStatCard("Ingresos", income, Colors.green)),
                const SizedBox(width: 15),
                Expanded(child: _buildStatCard("Gastos", totalExpenses, Colors.redAccent)),
              ],
            ),
            const SizedBox(height: 30),

            const Text("Flujo de Caja", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            _buildCashFlowChart(income, totalExpenses),

            const SizedBox(height: 30),
            const Text("Actividad Reciente", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),

            // AQUÃ ESTABA EL ERROR: Ahora le pasamos el transactionProvider
            _buildRecentActivity(transactionNotifier),
          ],
        ),
      ),
    );
  }

  // --- COMPONENTES DE LA INTERFAZ (Tu diseÃ±o intacto) ---

  Widget _buildNetWorthCard(double amount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF4A47F6),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF4A47F6).withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          const Text("Patrimonio Neto", style: TextStyle(color: Colors.white70, fontSize: 16)),
          const SizedBox(height: 10),
          Text("Q${currencyFormat.format(amount)}",
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, double amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withValues(alpha: 0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text("Q${currencyFormat.format(amount)}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCashFlowChart(double inAmt, double outAmt) {
    return SizedBox(
      height: 150,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (inAmt > outAmt ? inAmt : outAmt) * 1.2 == 0 ? 100 : (inAmt > outAmt ? inAmt : outAmt) * 1.2, // Evitar error si todo estÃ¡ en 0
          barGroups: [
            BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: inAmt, color: Colors.green, width: 25, borderRadius: BorderRadius.circular(6))]),
            BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: outAmt, color: Colors.redAccent, width: 25, borderRadius: BorderRadius.circular(6))]),
          ],
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text(v == 0 ? 'Entrada' : 'Salida', style: const TextStyle(fontSize: 12)))),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(TransactionProvider provider) {
    final transactions = provider.transactions;

    if (transactions.isEmpty) {
      return const Center(child: Text("No hay movimientos este mes", style: TextStyle(color: Colors.grey)));
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length > 5 ? 5 : transactions.length, // Mostramos los Ãºltimos 5
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = transactions[index];
        final isIncome = item.type == 'income'; // Verificamos si es ingreso

        // EL SOBRE MÃGICO: Dismissible (Deslizar para eliminar)
        return Dismissible(
          key: Key(item.id), // Firebase ID
          direction: DismissDirection.endToStart, // Solo deslizar de derecha a izquierda
          background: Container(
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(15),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (direction) {
            // Le decimos al motor que borre el documento de Firebase
            provider.deleteTransaction(item.id);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Movimiento eliminado")),
            );
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (isIncome ? Colors.green : Colors.redAccent).withValues(alpha: 0.1),
              child: Icon(
                  isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                  color: isIncome ? Colors.green : Colors.redAccent,
                  size: 18
              ),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(DateFormat('dd MMM').format(item.date)),
            trailing: Text(
              "${isIncome ? '+' : '-'}Q${currencyFormat.format(item.amount)}",
              style: TextStyle(
                  color: isIncome ? Colors.green : Colors.redAccent,
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(UserProvider userNotifier) {
    final String userName = userNotifier.currentUser?.displayName ?? "Usuario";

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Hola,", style: TextStyle(fontSize: 14, color: Colors.grey)),
          Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.redAccent),
          onPressed: () async {
            // 1. Cerramos la sesiÃ³n en Firebase
            await userNotifier.signOut();

            // 2. RedirecciÃ³n manual y segura bajo el enfoque Splash Boot
            if (mounted) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (route) => false, // Elimina todas las pantallas previas del stack de navegaciÃ³n
              );
            }
          },
        ),
      ],
    );
  }
}