// Archivo: lib/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'auth_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_rounded, size: 100, color: Color(0xFF4A47F6)),
              const SizedBox(height: 20),
              const Text("Finavid", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Toma el control de tu dinero", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 60),

              // OPCIÓN A: ANÓNIMO
              ElevatedButton(
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () => context.read<UserProvider>().signInAnonymously(),
                child: const Text("Probar como Invitado"),
              ),

              const SizedBox(height: 20),

              // OPCIÓN B: CUENTA EXISTENTE
              OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AuthScreen())),
                child: const Text("Ya tengo una cuenta"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}