// Archivo: lib/screens/auth/welcome_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

// Importamos las pantallas a donde vamos a dirigir al usuario
import 'setup_profile_screen.dart';
import '../main_layout.dart';

class WelcomeScreen extends StatelessWidget {
  // Parámetro crucial: nos dice si viene de registrarse o de iniciar sesión
  final bool isNewUser;

  const WelcomeScreen({super.key, required this.isNewUser});

  @override
  Widget build(BuildContext context) {
    // Leemos el proveedor para obtener el nombre del usuario si ya existe
    final userProvider = Provider.of<UserProvider>(context);
    // Extraemos el nombre. Si es nuevo, dirá "Usuario" temporalmente.
    final String userName = userProvider.currentUser?.displayName ?? 'Usuario';

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono dinámico según si es nuevo o no
              Icon(
                  isNewUser ? Icons.celebration_rounded : Icons.waving_hand_rounded,
                  size: 100,
                  color: const Color(0xFF4A47F6)
              ),
              const SizedBox(height: 30),

              // Texto principal "Camaleón"
              Text(
                isNewUser ? "¡Gracias por unirte!" : "¡Bienvenido de vuelta,\n$userName!",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 15),

              // Subtítulo
              Text(
                isNewUser
                    ? "Tus datos financieros ahora están seguros y guardados en la nube."
                    : "Es excelente verte de nuevo. Continuemos tu camino financiero.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 16, height: 1.5),
              ),

              const SizedBox(height: 60),

              // Botón Único de Continuar con la Lógica de Navegación
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A47F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    if (isNewUser) {
                      // FLUJO REGISTRO: Va a configurar su perfil (Nombre, Edad, Moneda)
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const SetupProfileScreen()),
                      );
                    } else {
                      // FLUJO LOGIN: Como ya tiene perfil, lo mandamos directo al Layout
                      // Usamos pushAndRemoveUntil para que no pueda regresar atrás
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
                            (route) => false,
                      );
                    }
                  },
                  child: const Text(
                    "Continuar",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}