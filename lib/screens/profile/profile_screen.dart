import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importante para cerrar sesión
import '../../providers/user_provider.dart';
import '../budget_and_goals/goals/savings_goals_screen.dart';
import '../transactions/manage_categories_screen.dart';
// IMPORTAMOS LA PANTALLA DE AUTH QUE CREAMOS
import '../auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    // Verificamos si es un usuario invitado (Anónimo)
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
            // SECCIÓN DE CABECERA
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 35,
                    backgroundColor: Color(0xFF4A47F6),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAnonymous ? "Usuario Invitado" : (user?.displayName ?? "Usuario de Finavid"),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isAnonymous ? "Progreso no guardado" : (user?.email ?? ""),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // --- NUEVO: BOTÓN PARA GUARDAR CUENTA (Solo si es anónimo) ---
            if (isAnonymous)
              Container(
                margin: const EdgeInsets.only(bottom: 25),
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AuthScreen()),
                    );
                  },
                  icon: const Icon(Icons.cloud_upload_outlined, color: Colors.white),
                  label: const Text(
                    'Guardar mi cuenta / Iniciar Sesión',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A47F6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 2,
                  ),
                ),
              ),

            // OPCIONES DE PERFIL
            _buildProfileOption(Icons.savings_outlined, 'Mis Metas', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()));
            }),
            _buildProfileOption(Icons.category_outlined, 'Categorías de Gastos', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()));
            }),
            _buildProfileOption(Icons.notifications_none_outlined, 'Notificaciones', () {}),
            _buildProfileOption(Icons.security_outlined, 'Privacidad y Seguridad', () {}),
            _buildProfileOption(Icons.help_outline, 'Ayuda y Soporte', () {}),

            const SizedBox(height: 30),

            // BOTÓN DE CERRAR SESIÓN (Solo se muestra si NO es anónimo)
            if (!isAnonymous)
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar Sesión?'),
        content: const Text('¿Estás seguro de que deseas salir de Finavid?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) Navigator.pop(context);
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A47F6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4A47F6)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}