import 'package:flutter/material.dart';

import '../../features/auth/presentation/screens/welcome_screen.dart';



/// Router global de Finavid.
///
/// Durante el Sprint B04 este router únicamente define
/// la pantalla inicial de la aplicación.
///
/// La navegación interna continúa siendo responsabilidad
/// de los módulos ya migrados.
final class AppRouter {
  const AppRouter._();

  static Widget get initialScreen => const WelcomeScreen();
}