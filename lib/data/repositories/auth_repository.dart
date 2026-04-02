import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Escuchar los cambios de estado (si el usuario entra o sale)
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Obtener el usuario actual
  User? get currentUser => _auth.currentUser;

  // 1. Iniciar sesión de forma anónima (Fase 1 de tu arquitectura)
  Future<UserCredential?> signInAnonymously() async {
    try {
      return await _auth.signInAnonymously();
    } catch (e) {
      debugPrint("Error al iniciar sesión anónima: $e");
      return null;
    }
  }

  // 2. Registro con Email y Contraseña
  Future<UserCredential?> registerWithEmail(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Error al registrar: $e");
      throw Exception(_handleAuthError(e));
    }
  }

  // 3. Iniciar sesión con Email y Contraseña
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      debugPrint("Error al iniciar sesión: $e");
      throw Exception(_handleAuthError(e));
    }
  }

  // 4. Cerrar sesión
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Manejo de errores de Firebase para mostrarlos bonitos en la interfaz
  String _handleAuthError(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'user-not-found': return 'No se encontró un usuario con ese correo.';
        case 'wrong-password': return 'Contraseña incorrecta.';
        case 'email-already-in-use': return 'Este correo ya está registrado.';
        case 'weak-password': return 'La contraseña es muy débil (mínimo 6 caracteres).';
        default: return 'Error de autenticación: ${e.message}';
      }
    }
    return 'Ocurrió un error inesperado.';
  }
}