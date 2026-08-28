import 'package:flutter/material.dart';

import 'app_bootstrap.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

/// Punto de composición principal de la aplicación.
///
/// Esta clase configura MaterialApp utilizando el tema y
/// el router global. No contiene lógica de negocio ni
/// inicialización de servicios.
class FinavidApp extends StatelessWidget {
  const FinavidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBootstrap(
      child: MaterialApp(
        title: 'Finavid',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: AppRouter.initialScreen,
      ),
    );
  }
}
