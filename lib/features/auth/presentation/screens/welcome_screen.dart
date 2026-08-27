import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../app/layout/main_layout.dart';
import 'auth_screen.dart';



class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4A47F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const Spacer(),
              const Icon(Icons.account_balance_wallet_rounded, size: 80, color: primaryColor),
              const SizedBox(height: 20),
              const Text("FinanzaGT", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Tu dinero, bajo control.", style: TextStyle(color: Colors.grey)),
              const Spacer(),

              // BOTÓN 1: REGISTRARSE (Flujo Pro)
              _buildButton(
                text: "Crear una cuenta",
                color: primaryColor,
                textColor: Colors.white,
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AuthScreen()),
                ),
              ),

              const SizedBox(height: 15),

              // BOTÓN 2: INICIAR SESIÓN (Para usuarios existentes)
              _buildButton(
                text: "Ya tengo cuenta",
                color: Colors.white,
                textColor: primaryColor,
                isBorder: true,
                onPressed: () {
                  // Conectado directamente a tu pantalla de Login
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              // OPCIÓN 3: INVITADO (Anonimato)
              TextButton(
                onPressed: () async {
                  try {
                    // 1. Iniciamos sesión en Firebase
                    await FirebaseAuth.instance.signInAnonymously();

                    // 2. NAVEGACIÓN MANUAL (Reemplaza al AuthWrapper)
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
                            (route) => false, // Esto destruye el historial para que no puedan regresar
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error al entrar: $e")));
                  }
                },
                child: const Text(
                  "Continuar como invitado",
                  style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
    bool isBorder = false
  }) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: isBorder ? const BorderSide(color: Color(0xFF4A47F6)) : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}