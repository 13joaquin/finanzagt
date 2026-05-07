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
            // --- 1. SECCIÓN DINÁMICA (ANÓNIMO VS REGISTRADO) ---
            if (isAnonymous)
              _buildAnonymousView(context)
            else
              _buildRegisteredView(context, user?.displayName ?? "Usuario", user?.email ?? "", userProvider),

            const SizedBox(height: 30),

            // --- 2. CONFIGURACIONES COMUNES ---
            const Align(
              alignment: Alignment.centerLeft,
              child: Text("Configuración", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            ),
            const SizedBox(height: 15),

            _buildOptionTile(
              icon: Icons.category_rounded,
              title: 'Gestionar Categorías',
              color: Colors.orange,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ManageCategoriesScreen())),
            ),
            _buildOptionTile(
              icon: Icons.track_changes_rounded,
              title: 'Metas de Ahorro',
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SavingsGoalsScreen())),
            ),
          ],
        ),
      ),
    );
  }

  // --- VISTA PARA INVITADOS (Con Inicio de Sesión) ---
  Widget _buildAnonymousView(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2D31FA), Color(0xFF5D58FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          const Icon(Icons.account_circle_outlined, color: Colors.white, size: 60),
          const SizedBox(height: 15),
          const Text(
            "Modo Invitado",
            style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Inicia sesión para respaldar tus finanzas y sincronizar tus datos.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 25),
          // BOTÓN DE INICIO DE SESIÓN (SOLICITADO)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF2D31FA),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            icon: const Icon(Icons.login_rounded),
            label: const Text("INICIAR SESIÓN", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen())),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen())),
            child: const Text("¿No tienes cuenta? Regístrate aquí", style: TextStyle(color: Colors.white, decoration: TextDecoration.underline)),
          )
        ],
      ),
    );
  }

  // --- VISTA PARA REGISTRADOS (Con Cerrar Sesión) ---
  Widget _buildRegisteredView(BuildContext context, String name, String email, UserProvider provider) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: Text(name[0].toUpperCase(), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // BOTÓN DE CERRAR SESIÓN (SOLICITADO)
        _buildOptionTile(
          icon: Icons.logout_rounded,
          title: 'Cerrar Sesión',
          color: Colors.redAccent,
          onTap: () => _showLogoutDialog(context, provider),
        ),
      ],
    );
  }

  // --- WIDGET GENÉRICO PARA OPCIONES ---
  Widget _buildOptionTile({required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: BorderSide(color: Colors.grey.withOpacity(0.1))),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Cerrar Sesión?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Saldrás de tu cuenta actual. Podrás volver a entrar cuando quieras.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              Navigator.pop(context);
              await provider.signOut(); // Esto limpia los datos y vuelve al modo anónimo
            },
            child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}