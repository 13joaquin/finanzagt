// Archivo: lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. IMPORTANTE: Esto corrige el error de "FirebaseOptions cannot be null"
import 'firebase_options.dart';

// Importaciones de Providers
import 'providers/user_provider.dart';
import 'providers/sanctuary_provider.dart';
import 'providers/debt_provider.dart';
import 'providers/GoalProvider.dart';
import 'providers/transaction_provider.dart';
import 'providers/lesson_provider.dart';

// Importaciones de Pantallas
import 'screens/Onboarding/onboarding.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/main_layout.dart';
import 'screens/auth/setup_profile_screen.dart';// Añadido para absorber la lógica de AuthGate

void main() async {
  // Asegura que Flutter esté listo antes de iniciar Firebase
  WidgetsFlutterBinding.ensureInitialized();

  // 2. CORRECCIÓN DE FIREBASE: Aquí activamos las opciones para que no falle
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. LÓGICA PARA DECIDIR LA PANTALLA INICIAL (Lo que buscabas)
  final prefs = await SharedPreferences.getInstance();
  final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  Widget screenPrincipal;

  if (!hasSeenOnboarding) {
    // Si es la primera vez que abre la app
    screenPrincipal = const OnboardingScreen();
  } else {
    // Ya vio el onboarding, verificamos Firebase Auth de forma sincrónica
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      // No hay sesión activa en el dispositivo
      screenPrincipal = const WelcomeScreen();
    } else {
      // Hay sesión activa. Verificamos el estado del perfil.
      if (currentUser.isAnonymous) {
        // Invitados pasan directo
        screenPrincipal = const MainLayoutScreen();
      }else{
        // Es cuenta registrada: Leemos Firestore una sola vez antes de arrancar
        try {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();
          if (userDoc.exists && (userDoc.data()?['profile_completed'] ?? true)) {
            // Perfil completo -> Al Layout Principal
            screenPrincipal = const MainLayoutScreen();
          }else{
            // Perfil incompleto o documento no creado -> A completar perfil
            screenPrincipal = const SetupProfileScreen();
          }
        } catch (e) {
          // Fallback seguro: Si hay error de red al iniciar, pasamos al layout para no bloquear la app
          screenPrincipal = const MainLayoutScreen();
        }
      }
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => SanctuaryProvider()),
        ChangeNotifierProvider(create: (_) => LessonProvider()),

        // Providers con dependencia de Usuario
        ChangeNotifierProxyProvider<UserProvider, GoalProvider>(
          create: (_) => GoalProvider(),
          update: (_, userProvider, goalProvider) {
            final uid = userProvider.currentUser?.uid;
            if(uid != null) goalProvider!.listenToGoals(uid);
            return goalProvider!;
          },
        ),
        ChangeNotifierProxyProvider<UserProvider, DebtProvider>(
          create: (_) => DebtProvider(),
          update: (_, userProvider, debtProvider) {
            final uid = userProvider.currentUser?.uid;
            debtProvider!..updateUser(uid);
            return debtProvider!;
          },
        ),
        ChangeNotifierProxyProvider<UserProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, userProvider, transactionProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) transactionProvider!..listenToTransactions(uid);
            return transactionProvider!;
          },
        ),
      ],
      // 4. PASAMOS LA PANTALLA DECIDIDA A LA APP
      child: MyApp(pantallaInicial: screenPrincipal),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget pantallaInicial;

  const MyApp({super.key, required this.pantallaInicial});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinanzaGT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A47F6),
          primary: const Color(0xFF4A47F6),
        ),
        useMaterial3: true,
      ),
      // 5. AQUÍ SE USA: Ya no es fijo OnboardingScreen, ahora es dinámico
      home: pantallaInicial,
    );
  }
}