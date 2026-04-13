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
    // Escuchamos al UserProvider para obtener los datos reales
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
            // SECCIÓN DE CABECERA CON DATOS REALES
            Container(
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
                      user?.displayName[0].toUpperCase() ?? "U",
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF4A47F6)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Usuario',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          isAnonymous ? 'Cuenta Invitado' : (user?.email ?? 'Sin correo'),
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // OPCIONES DE CONFIGURACIÓN
            _buildProfileOption(Icons.category_outlined, 'Gestionar Categorías', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()));
            }),
            _buildProfileOption(Icons.track_changes_rounded, 'Metas de Ahorro', () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()));
            }),

            // Si es anónimo, mostrar opción de proteger cuenta
            if (isAnonymous)
              _buildProfileOption(Icons.security_rounded, 'Proteger mi cuenta con Email', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
              }),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),

            // BOTÓN DE CERRAR SESIÓN (Actualizado)
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
          ],
        ),
      ),
    );
  }

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
              await provider.signOut();
              // El AuthGate nos llevará automáticamente a la WelcomeScreen
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