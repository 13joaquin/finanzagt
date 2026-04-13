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
        _currentUser = null;
        notifyListeners();
      } else {
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
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          isAnonymous: firebaseUser.isAnonymous,
          displayName: firebaseUser.isAnonymous ? "Usuario Invitado" : (firebaseUser.displayName ?? "Nuevo Usuario"),
          email: firebaseUser.email,
          safeToSpend: 0.0,
          netWorth: 0.0,
          preferences: {
            'currency': 'GTQ',
            'budgetModel': 'simplified',
          },
        );

        await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toFirestore());
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar perfil de usuario: $e");
    }
  }

  // --- NUEVOS MÉTODOS PARA ACTUALIZAR EL PERFIL ---

  /// Actualiza solo el nombre (Para resolver tu error actual)
  Future<void> updateDisplayName(String newName) async {
    if (_currentUser == null) return;
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'display_name': newName,
      });

      // Recargamos el perfil local para que la UI se entere del cambio
      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      _currentUser = UserModel.fromFirestore(userDoc);

      notifyListeners();
    } catch (e) {
      debugPrint("Error al actualizar nombre: $e");
      rethrow;
    }
  }

  /// Método más completo para la pantalla de SetupProfile
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

      // Sincronizamos el estado local
      final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
      _currentUser = UserModel.fromFirestore(userDoc);

      notifyListeners();
    } catch (e) {
      debugPrint("Error al completar perfil: $e");
      rethrow;
    }
  }

  // --- MÉTODOS EXISTENTES ---

  Future<void> signInAnonymously() async {
    await _authRepo.signInAnonymously();
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}