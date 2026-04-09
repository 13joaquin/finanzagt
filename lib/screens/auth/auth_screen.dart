import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = false; // Alterna entre Login y Registro
  bool _isLoading = false;

  Future<void> _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Por favor llena todos los campos");
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isLogin) {
        // --- INICIAR SESIÓN (Usuario ya existente) ---
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        _showMessage("¡Bienvenido de vuelta!", isSuccess: true);
        if (mounted) Navigator.pop(context);
      } else {
        // --- REGISTRARSE (Vincular cuenta anónima o crear nueva) ---
        User? currentUser = _auth.currentUser;

        if (currentUser != null && currentUser.isAnonymous) {
          // Si es anónimo, VINCULAMOS el correo para no perder sus gastos
          AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
          await currentUser.linkWithCredential(credential);
          _showMessage("¡Cuenta guardada con éxito!", isSuccess: true);
        } else {
          // Si no hay cuenta, creamos una desde cero
          await _auth.createUserWithEmailAndPassword(email: email, password: password);
          _showMessage("¡Cuenta creada con éxito!", isSuccess: true);
        }
        if (mounted) Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      // Manejo de errores amigable
      String errorMsg = "Ocurrió un error";
      if (e.code == 'weak-password') errorMsg = "La contraseña es muy débil.";
      if (e.code == 'email-already-in-use') errorMsg = "Este correo ya está registrado.";
      if (e.code == 'user-not-found' || e.code == 'wrong-password') errorMsg = "Correo o contraseña incorrectos.";
      if (e.code == 'credential-already-in-use') errorMsg = "Este correo ya está vinculado a otra cuenta.";

      _showMessage(errorMsg);
    } catch (e) {
      _showMessage(e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green : Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icono / Logo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A47F6).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_person_outlined, size: 80, color: Color(0xFF4A47F6)),
              ),
              const SizedBox(height: 30),

              Text(
                _isLogin ? "Bienvenido de vuelta" : "Protege tu Progreso",
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _isLogin
                    ? "Inicia sesión para ver tu presupuesto."
                    : "Regístrate para no perder tus gastos guardados.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Formularios
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo electrónico",
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña",
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 30),

              // Botón Principal
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
                    _isLogin ? "Iniciar Sesión" : "Crear Cuenta",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Alternar entre Login y Registro
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(
                  _isLogin ? "¿No tienes cuenta? Regístrate aquí" : "¿Ya tienes cuenta? Inicia sesión",
                  style: const TextStyle(color: Color(0xFF4A47F6), fontWeight: FontWeight.bold),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}