import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

// Importamos tus Providers
import 'providers/user_provider.dart';
import 'providers/transaction_provider.dart';

// Importamos el layout principal
import 'package:finanzagt/screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // 1. Iniciamos el UserProvider (él mismo se encarga de escuchar a Firebase)
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ),

        // 2. Usamos ProxyProvider para que el TransactionProvider siempre tenga el UID real
        // Esto elimina la necesidad de pasar 'test_user_123' a mano
        ChangeNotifierProxyProvider<UserProvider, TransactionProvider>(
          create: (_) => TransactionProvider(),
          update: (_, userProvider, txProvider) {
            final uid = userProvider.currentUser?.uid;
            if (uid != null) {
              // En cuanto tenemos UID, empezamos a escuchar sus transacciones reales
              txProvider!.listenToTransactions(uid);
            }
            return txProvider!;
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
// Este widget decide si mostrar la carga de inicio o el Dashboard
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    // Si aún no hay un usuario cargado en el Provider
    if (userProvider.currentUser == null) {
      // Disparamos el inicio de sesión anónimo automático (Paso 1 de tu arquitectura)
      userProvider.signInAnonymously();

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

    // ¡Si ya tenemos usuario, entramos a la App!
    return const MainLayoutScreen();
  }
}