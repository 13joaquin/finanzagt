import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Importamos el Provider de usuario
import '../../providers/user_provider.dart';
// Importamos las pantallas para la navegación
import '../budget_and_goals/goals/savings_goals_screen.dart';
import '../transactions/manage_categories_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Escuchamos al UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blueGrey[900],
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Añadido por si hay pantallas pequeñas
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // SECCIÓN DE CABECERA (DATOS REALES)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF4A47F6).withOpacity(0.1),
                    child: Text(
                      user?.displayName?.substring(0, 1).toUpperCase() ?? "U",
                      style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Color(0xFF4A47F6)),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.displayName ?? 'Cargando...',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          user?.email ?? 'usuario@finavid.gt',
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: Colors.grey),
                    onPressed: () {
                      // TODO: Implementar edición de perfil
                    },
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            // SECCIÓN DE OPCIONES
            _buildProfileOption(
                Icons.account_balance_wallet_outlined,
                'Mis Cuentas',
                    () => _showComingSoon(context)
            ),
            _buildProfileOption(
                Icons.category_outlined,
                'Gestionar Categorías',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()))
            ),
            _buildProfileOption(
                Icons.track_changes_rounded,
                'Metas de Ahorro',
                    () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()))
            ),
            _buildProfileOption(
                Icons.notifications_none_rounded,
                'Notificaciones',
                    () => _showComingSoon(context)
            ),
            _buildProfileOption(
                Icons.security_rounded,
                'Seguridad y Privacidad',
                    () => _showComingSoon(context)
            ),

            const SizedBox(height: 40),

            // BOTÓN DE CERRAR SESIÓN
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE APOYO ---

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Esta función estará disponible pronto')),
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
              onPressed: () {
                // Aquí llamarías a authRepository.signOut()
                Navigator.pop(context);
              },
              child: const Text('Sí, salir', style: TextStyle(color: Colors.red))
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
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
      ),
    );
  }
}