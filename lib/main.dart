import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // 1. Importar Provider
import 'firebase_options.dart';
// Importamos el layout principal y nuestro nuevo Provider
import 'package:finanzagt/screens/main_layout.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. REEMPLAZA LA INICIALIZACIÓN POR ESTA:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider()..listenToUserChanges('test_user_123'),
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2E7D32)), // Verde Finavid
        useMaterial3: true,
      ),
      home: const MainLayoutScreen(),
    );
  }
}