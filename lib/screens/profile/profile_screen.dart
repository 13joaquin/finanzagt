// Archivo: lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../budget_and_goals/goals/savings_goals_screen.dart';
import '../transactions/manage_categories_screen.dart';
import '../auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? true;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blueGrey[900],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- SECCIÓN DE CABECERA Y CONVERSIÓN ---
            if (isAnonymous)
              _buildConversionSection(context) // Muestra banner de registro y botón de login
            else
              _buildRegisteredHeader(user?.displayName ?? "Usuario", user?.email ?? ""), // Cabecera normal

            const SizedBox(height: 30),

            // --- OPCIONES DE CONFIGURACIÓN ---
            _buildProfileOption(Icons.category_outlined, 'Gestionar Categorías', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()));
            }),
            _buildProfileOption(Icons.track_changes_rounded, 'Metas de Ahorro', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()));
            }),

            const SizedBox(height: 20),

            // --- BOTÓN DE CERRAR SESIÓN (SOLO REALES) ---
            if (!isAnonymous) ...[
              const Divider(),
              const SizedBox(height: 20),
              ListTile(
                onTap: () => _showLogoutDialog(context, userProvider),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.logout_rounded, color: Colors.red),
                ),
                title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.red),
              ),
            ]
          ],
        ),
      ),
    );
  }

  // --- WIDGET PARA USUARIOS ANÓNIMOS ---
  Widget _buildConversionSection(BuildContext context) {
    return Column(
      children: [
        // Botón 1: Registrarse (Destacado)
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF4A47F6), Color(0xFF6C63FF)]),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: const Color(0xFF4A47F6).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 45),
              const SizedBox(height: 15),
              const Text(
                "Guarda tu progreso",
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Crea una cuenta para no perder tus gastos y sincronizarlos en la nube.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF4A47F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () {
                  // Abre AuthScreen para REGISTRARSE
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                },
                child: const Text("Crear mi cuenta", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Botón 2: Ya tengo cuenta (Sutil)
        OutlinedButton(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            side: const BorderSide(color: Color(0xFF4A47F6)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () {
            // Abre AuthScreen para INICIAR SESIÓN
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
          },
          child: const Text("Ya tengo una cuenta. Iniciar sesión", style: TextStyle(color: Color(0xFF4A47F6), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  // --- WIDGET PARA USUARIOS REGISTRADOS ---
  Widget _buildRegisteredHeader(String name, String email) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: const Color(0xFF4A47F6).withOpacity(0.1),
            child: Text(
              name[0].toUpperCase(),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A47F6)),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  email,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ... (El resto de tus métodos _showLogoutDialog y _buildProfileOption se quedan igual)
  void _showLogoutDialog(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('Tus datos se guardan de forma segura en la nube.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Cerramos el diálogo primero
              await provider.signOut(); // Al hacer signOut, el motor silencioso crea un invitado nuevo
            },
            child: const Text('Sí, salir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: const Color(0xFF4A47F6).withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: const Color(0xFF4A47F6)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      ),
    );
  }
}