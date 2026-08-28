// Archivo: lib/screens/profile/profile_registered_screen.dart
import 'package:flutter/material.dart';import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../../auth/presentation/screens/welcome_screen.dart';


// <-- NUEVA IMPORTACIÓN PARA EL SPLASH BOOT

class ProfileRegisteredSection extends ConsumerWidget {
  const ProfileRegisteredSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    const Color primaryColor = Color(0xFF4A47F6);

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        CircleAvatar(
          radius: 40,
          backgroundColor: primaryColor.withValues(alpha: 0.1),
          child: Text(
            user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : "U",
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          user.displayName,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          user.email ?? "Sin correo verificado",
          style: const TextStyle(color: Colors.grey, fontSize: 13),
        ),
        const SizedBox(height: 6),
        Chip(
          label: const Text("PRO", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
          backgroundColor: Colors.amber[700],
          padding: const EdgeInsets.symmetric(horizontal: 10),
          side: BorderSide.none,
        ),
        const SizedBox(height: 25),

        _buildSectionLabel("Configuración de Cuenta"),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.cake_outlined, color: primaryColor, size: 22),
                title: const Text("Edad", style: TextStyle(fontSize: 15)),
                trailing: Text(
                  "${user.preferences['age'] ?? 'No especificada'} años",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const Divider(height: 1, indent: 50),
              ListTile(
                leading: const Icon(Icons.payments_outlined, color: primaryColor, size: 22),
                title: const Text("Moneda Principal", style: TextStyle(fontSize: 15)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.currency ?? 'GTQ',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 25),

        // Botón de Salida
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _showLogoutDialog(context, ref),
            icon: const Icon(Icons.logout, color: Colors.redAccent, size: 18),
            label: const Text("Cerrar Sesión", style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cerrar Sesión?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Saldrás de tu cuenta actual. Podrás volver a entrar cuando quieras.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.pop(context); // Cierra el diálogo
              await ref.read(userProvider.notifier).signOut(); // Cierra la sesión en Firebase
              // CAMBIO CRÍTICO: Redirección manual del Splash Boot
              if (context.mounted){
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                      (router) => false,
                );
              }
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
        ),
      ),
    );
  }
}