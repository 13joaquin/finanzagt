import 'package:finanzagt/screens/auth/welcome_screen.dart';
import 'package:finanzagt/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// 1. Importamos tus Providers (¡Añadimos el nuevo!)
import 'providers/user_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/sanctuary_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/GoalProvider.dart';
import 'providers/expenseProvider.dart';
import 'providers/budget_provider.dart';// <-- NUEVO: Importación del Santuario

// Importamos pantallas
import 'package:finanzagt/screens/main_layout.dart';
import 'package:finanzagt/screens/auth/welcome_screen.dart';
import 'package:finanzagt/screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    // EL "DIRECTORIO" DE TU APLICACIÓN
    MultiProvider(
      providers: [
        // Tienda 1: Maneja al Usuario
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),

        // Tienda 2: Maneja las Transacciones (Lo conservamos por si lo usas en otras pantallas)
        ChangeNotifierProxyProvider<UserProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, userProvider, txProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) {
              txProvider!.listenToTransactions(uid);
            }
            return txProvider!;
          },
        ),

        // Tienda 3: Maneja las Deudas
        ChangeNotifierProxyProvider<UserProvider, DebtProvider>(
          create: (_) => DebtProvider(),
          update: (_, userProvider, debtProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) {
              debtProvider!.listenToDebts(uid);
            }
            return debtProvider!;
          },
        ),

        // Tienda 4: Maneja las Metas de Ahorro
        ChangeNotifierProxyProvider<UserProvider, GoalProvider>(
          create: (_) => GoalProvider(),
          update: (_, userProvider, goalProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) {
              goalProvider!.listenToGoals(uid);
            }
            return goalProvider!;
          },
        ),

        // Tienda 5: Maneja los Gastos (Fijos y Flexibles)
        ChangeNotifierProxyProvider<UserProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, userProvider, expenseProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) {
              expenseProvider!.listenToExpenses(uid);
            }
            return expenseProvider!;
          },
        ),

        // Tienda 6: Maneja el Presupuesto General y Límites
        ChangeNotifierProxyProvider<UserProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (_, userProvider, budgetProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) {
              budgetProvider!.listenToBudget(uid);
            }
            return budgetProvider!;
          },
        ),

        // Tienda 7: EL GRAN CABLEADO DEL SANTUARIO <-- AHORA AL FINAL
        // Escucha automáticamente a: Metas (Goal), Deudas (Debt) y Gastos (Expense)
        ChangeNotifierProxyProvider3<GoalProvider, DebtProvider, ExpenseProvider, SanctuaryProvider>(
          create: (_) => SanctuaryProvider(),
          update: (_, goalProv, debtProv, expenseProv, sanctuary) {
            // Cada vez que ahorres, pagues una deuda o gastes, esta función se dispara sola
            return sanctuary!..updateFromProviders(
              goals: goalProv.goals,
              debts: debtProv.debts,
              totalExpenses: expenseProv.totalFixedAmount + expenseProv.totalFlexibleAmount,
            );
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finavid',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A47F6),
          primary: const Color(0xFF4A47F6),
        ),
        useMaterial3: true,
      ),
      // Definimos el AuthWrapper como la pantalla inicial
      home: const AuthWrapper(),
    );
  }
}

// --- EL PORTERO (AUTH WRAPPER) ---
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Si aún no hay un usuario cargado en el Provider
    if (userProvider.currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF4A47F6)),
              SizedBox(height: 20),
              Text(
                "Preparando tu billetera...",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

// ¡Si ya tenemos usuario, entra al Guardián que decidirá si va al Setup o al Dashboard!
  return const AuthGate();
  }
}