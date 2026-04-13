// Archivo: lib/screens/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  Future<void> _submitAuth() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // LOGIN NORMAL
        await _auth.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim()
        );
      } else {
        // REGISTRO O VINCULACIÓN
        User? currentUser = _auth.currentUser;
        AuthCredential credential = EmailAuthProvider.credential(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim()
        );

        if (currentUser != null && currentUser.isAnonymous) {
          // CONVERTIR ANÓNIMO A REAL (No pierde sus gastos)
          await currentUser.linkWithCredential(credential);
        } else {
          // CREAR CUENTA NUEVA DESDE CERO
          await _auth.createUserWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim()
          );
        }
      }
      if (mounted) Navigator.pop(context); // El AuthGate hará el resto
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? "Iniciar Sesión" : "Crear Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Correo")),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: "Contraseña"), obscureText: true),

            if (_isLogin)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ForgotPasswordScreen())),
                  child: const Text("¿Olvidaste tu contraseña?"),
                ),
              ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAuth,
                child: _isLoading ? const CircularProgressIndicator() : Text(_isLogin ? "Entrar" : "Registrarme"),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(_isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Logueate"),
            )
          ],
        ),
      ),
    );
  }
}