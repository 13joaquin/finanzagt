import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/repositories/auth_repository.dart';

class UserProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _currentUser;
  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  UserProvider() {
    // Empezamos a escuchar el estado de autenticación desde que nace el Provider
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authRepo.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        // El usuario cerró sesión o no está logueado
        _currentUser = null;
        notifyListeners();
      } else {
        // El usuario está logueado, vamos a cargar sus datos de Firestore
        await _loadOrCreateUserProfile(firebaseUser);
      }
    });
  }

  Future<void> _loadOrCreateUserProfile(User firebaseUser) async {
    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        // CORRECCIÓN 1: Le pasamos el DocumentSnapshot completo al Modelo
        _currentUser = UserModel.fromFirestore(userDoc);
      } else {
        // CORRECCIÓN 2: Usuario nuevo (primer ingreso), añadimos 'preferences' y adaptamos los campos
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          isAnonymous: firebaseUser.isAnonymous,
          displayName: firebaseUser.isAnonymous ? "Usuario Invitado" : (firebaseUser.displayName ?? "Nuevo Usuario"),
          email: firebaseUser.email,
          safeToSpend: 0.0,
          netWorth: 0.0,
          preferences: {
            'currency': 'GTQ',
            'budgetModel': 'simplified', // Según la Arquitectura de Finavid
          },
        );

        // Guardamos en Firestore para la posteridad
        await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toFirestore());
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar perfil de usuario: $e");
    }
  }

  // Método para iniciar sesión anónima desde la UI
  Future<void> signInAnonymously() async {
    await _authRepo.signInAnonymously();
    // No hace falta hacer nada más aquí, _listenToAuthChanges se encargará del resto
  }

  // Método para cerrar sesión
  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}