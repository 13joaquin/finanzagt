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
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authRepo.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        // --- INICIO SILENCIOSO ---
        // Si no hay nadie conectado (al abrir la app o al cerrar sesión),
        // creamos una cuenta anónima automáticamente.
        _currentUser = null;
        notifyListeners();

        try {
          debugPrint("Iniciando sesión anónima automáticamente...");
          await _authRepo.signInAnonymously();
          // Al hacer esto, Firebase volverá a disparar este listener,
          // pero ahora firebaseUser YA NO será nulo, y pasará al 'else' de abajo.
        } catch (e) {
          debugPrint("Error en inicio silencioso: $e");
        }
      } else {
        // Si hay un usuario (Anónimo o con Correo), cargamos su perfil
        await _loadOrCreateUserProfile(firebaseUser);
      }
    });
  }

  Future<void> _loadOrCreateUserProfile(User firebaseUser) async {
    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
      } else {
        // Solo se crea el documento la primera vez que Firebase genera el ID
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          isAnonymous: firebaseUser.isAnonymous,
          displayName: firebaseUser.isAnonymous ? "Invitado" : "Usuario",
          email: firebaseUser.email,
          safeToSpend: 0.0,
          netWorth: 0.0,
          preferences: {'currency': 'GTQ'},
          profileCompleted: false,
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toFirestore());
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar perfil de usuario: $e");
    }
  }

  // --- MÉTODOS PARA ACTUALIZAR EL PERFIL ---

  Future<void> updateDisplayName(String newName) async {
    if (_currentUser == null) return;
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'display_name': newName,
      });

      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      _currentUser = UserModel.fromFirestore(userDoc);
      notifyListeners();
    } catch (e) {
      debugPrint("Error al actualizar nombre: $e");
      rethrow;
    }
  }

  Future<void> completeUserProfile({
    required String name,
    required int age,
    required String currency,
  }) async {
    if (_currentUser == null) return;
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'display_name': name,
        'age': age,
        'currency': currency,
        'profile_completed': true,
      });

      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      _currentUser = UserModel.fromFirestore(userDoc);
      notifyListeners();
    } catch (e) {
      debugPrint("Error al completar perfil: $e");
      rethrow;
    }
  }

  // --- MÉTODOS DE AUTENTICACIÓN ---

  Future<void> signOut() async {
    await _authRepo.signOut();
    // Nota: Al hacer signOut, firebaseUser será nulo, el listener lo detectará
    // y creará un invitado nuevo automáticamente. ¡Fricción Cero!
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}