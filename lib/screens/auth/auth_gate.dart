// Archivo: lib/screens/auth/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:finanzagt/screens/auth/setup_profile_screen.dart';
import 'package:finanzagt/screens/main_layout.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // 1. Pantalla de espera por si Firebase está cargando
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Color(0xFF4A47F6))),
      );
    }

    // 2. EL GUARDIÁN CORREGIDO:
    // ¿Es un usuario CON CORREO (!isAnonymous) pero NO ha completado su perfil? -> Al Setup
    if (!user.isAnonymous && !user.profileCompleted) {
      return const SetupProfileScreen();
    }

    // 3. FLUJO LIBRE:
    // Si es Invitado (pasa directo para probar) o si es Real y ya tiene su perfil -> Al Layout
    return const MainLayoutScreen();
  }
}