import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:finanzagt/screens/auth/welcome_screen.dart';
import 'package:finanzagt/screens/auth/setup_profile_screen.dart';
import 'package:finanzagt/screens/main_layout.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

   /* // 1. ¿No hay nadie? -> Bienvenida
    if (!userProvider.isAuthenticated) {
      return const WelcomeScreen();
    }
*/
    final user = userProvider.currentUser;

    // 2. ¿Hay alguien pero le falta el nombre/moneda? -> Setup
    if (user != null && !user.profileCompleted) {
      return const SetupProfileScreen();
    }

    // 3. ¿Todo listo? -> Vamos al Layout principal
    return const MainLayoutScreen();
  }
}