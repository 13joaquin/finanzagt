// Archivo: lib/main.dart
import 'package:finanzagt/screens/auth/welcome_screen.dart';
import 'package:finanzagt/screens/main_layout.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// 1. IMPORTACIONES ACTUALIZADAS
import 'providers/user_provider.dart';
import 'providers/sanctuary_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/GoalProvider.dart';
import 'providers/expenseProvider.dart';
import 'providers/budget_provider.dart';
import 'providers/transaction_provider.dart'; // <-- Agrega esta línea

// Importamos pantallas
import 'package:finanzagt/screens/auth/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // Manejo de Usuario
        ChangeNotifierProvider(create: (_) => UserProvider()),

        // El Santuario (El Árbol)
        ChangeNotifierProvider(create: (_) => SanctuaryProvider()),

        // NUEVOS PROVEEDORES ESPECIALIZADOS (Sustituyen a TransactionProvider)
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => DebtProvider()),

        // EL NUEVO CEREBRO: TransactionProvider (Maneja ingresos, gastos y ahorros)
        ChangeNotifierProxyProvider<UserProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, userProvider, transactionProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) {
              // Le pasamos el ID del usuario para que descargue sus transacciones
              transactionProvider!..listenToTransactions(uid);
            }
            return transactionProvider!;
          },
        ),
        // Tienda 5: Maneja los Gastos (¡Ahora enciende automáticamente!)
        ChangeNotifierProxyProvider<UserProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, userProvider, expenseProvider) {
            return expenseProvider!..updateUser(userProvider.currentUser?.uid);
          },
        ),

        // Tienda 6: Maneja el Presupuesto General y Límites
        ChangeNotifierProxyProvider<UserProvider, BudgetProvider>(
          create: (_) => BudgetProvider(),
          update: (_, userProvider, budgetProvider) {
            // Asumo que tu BudgetProvider también tendrá un updateUser.
            // Si te da error, coméntame cómo se llama la función allí.
            return budgetProvider!..updateUser(userProvider.currentUser?.uid);
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

    // Si aún no hay un usuario cargado
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

    // El AuthGate decidirá si va a Welcome o al MainLayout
    return const AuthGate();
  }
}