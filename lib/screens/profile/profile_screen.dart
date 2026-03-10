import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos el color de fondo consistente con el resto de la app
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.blueGrey[900], // Color de la flecha de retroceso y texto
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1 y 2. Contenedor con Imagen, Nombre y Correo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 50,
                      backgroundColor: Colors.grey[200],
                      child: Icon(Icons.person, color: Colors.grey[600], size: 60),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alex', // Nombre del usuario
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'alex@ejemplo.com.gt', // Correo con dominio de Guatemala como ejemplo
                          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 3. Lista de Opciones (Editar, Configuración, Notificaciones, Cuentas)
            Expanded(
              child: ListView(
                children: [
                  _buildProfileOption(Icons.person_outline, 'Editar Perfil', () {
                    debugPrint("Abrir Editar Perfil");
                  }),
                  _buildProfileOption(Icons.settings_outlined, 'Configuración General', () {}),
                  _buildProfileOption(Icons.notifications_outlined, 'Notificaciones', () {}),
                  _buildProfileOption(Icons.g_mobiledata_rounded, 'Vincular cuenta de Google', () {}),
                ],
              ),
            ),

            // 4. Botón de Cerrar Sesión (Destacado y separado en la parte inferior)
            SizedBox(
              width: double.infinity,
              height: 55,
              child: OutlinedButton.icon(
                onPressed: () {
                  // AQUI IRÁ LA LÓGICA DE FIREBASE AUTH PARA CERRAR SESIÓN
                  debugPrint("Cerrando sesión...");
                  Navigator.pop(context); // Por ahora solo regresa a la pantalla anterior
                },
                icon: const Icon(Icons.logout, color: Colors.redAccent),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.redAccent),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.redAccent.withValues(alpha: 0.05),
                ),
              ),
            ),
            const SizedBox(height: 20), // Margen inferior
          ],
        ),
      ),
    );
  }

  // Widget reutilizable para crear cada fila de opción en el perfil
  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4A47F6).withValues(alpha: 0.1), // Tonos morados/azules de la app
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF4A47F6)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}