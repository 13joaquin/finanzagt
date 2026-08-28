// Archivo: lib/screens/auth/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../app/layout/main_layout.dart';
import 'setup_profile_screen.dart';


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
  @override
  void dispose(){
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Por favor, completa todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- FLUJO LOGIN (USUARIO EXISTENTE) ---
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        User? user = userCredential.user;

        if (mounted && user != null) {
          // SPLASH BOOT: Verificamos el estado del perfil en Firestore de forma directa
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          Widget nextScreen;
          if (userDoc.exists && (userDoc.data()?['profile_completed'] == true)) {
            nextScreen = const MainLayoutScreen();
          } else {
            nextScreen = const SetupProfileScreen();
          }

          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => nextScreen),
                  (route) => false,
            );
          }
        }
      } else {
        // --- FLUJO REGISTRO (CONVERSIÓN DE ANÓNIMO) ---
        User? currentUser = _auth.currentUser;
        AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);

        if (currentUser != null && currentUser.isAnonymous) {
          // VINCULACIÓN: Pega los datos del invitado a la nueva cuenta de correo
          await currentUser.linkWithCredential(credential);
        } else {
          // Caso de respaldo si no hubiera usuario anónimo
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
        }

        if (mounted) {
          // Navegamos al Layout Principal
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
                (route) => false,
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "Ocurrió un error";
      if (e.code == 'email-already-in-use') {
        errorMessage = "Este correo ya tiene una cuenta. Intenta iniciar sesión.";
      } else if (e.code == 'wrong-password' || e.code == 'user-not-found') {
        errorMessage = "Correo o contraseña incorrectos.";
      }
      _showMessage(errorMessage);
    } catch (e) {
      _showMessage("Error inesperado: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_isLogin ? "Iniciar Sesión" : "Crear Cuenta"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Text(
              _isLogin ? "¡Bienvenido de vuelta!" : "Protege tus datos",
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              _isLogin
                  ? "Ingresa tus credenciales para continuar"
                  : "Al crear una cuenta, tus gastos y cubetas se guardarán para siempre.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: "Correo electrónico",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Contraseña",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A47F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                  _isLogin ? "Entrar" : "Registrarme y Guardar",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            TextButton(
              onPressed: () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? "¿No tienes cuenta? Regístrate" : "¿Ya tienes cuenta? Inicia sesión",
                style: const TextStyle(color: Color(0xFF4A47F6), fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}