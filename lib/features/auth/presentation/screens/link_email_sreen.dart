import 'package:flutter/material.dart';

class LinkEmailScreen extends StatefulWidget {
  const LinkEmailScreen({super.key});

  @override
  State<LinkEmailScreen> createState() => _LinkEmailScreenState();
}

class _LinkEmailScreenState extends State<LinkEmailScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _linkAccount() {
    // Aquí implementaremos FirebaseAuth.instance.currentUser!.linkWithCredential()
    // Por ahora, solo cerramos la pantalla como simulación.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cuenta vinculada con éxito (Simulación)'), backgroundColor: Colors.green),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4A47F6);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.blueGrey[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.cloud_sync, size: 50, color: Color(0xFF4A47F6)),
            const SizedBox(height: 20),
            Text('Asegura tus datos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
            const SizedBox(height: 10),
            Text('Crea una cuenta para guardar tu historial, presupuestos y acceder desde cualquier dispositivo.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            const SizedBox(height: 40),

            // Campo Correo
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                prefixIcon: const Icon(Icons.email_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 20),

            // Campo Contraseña
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                prefixIcon: const Icon(Icons.lock_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _linkAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Vincular Cuenta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}