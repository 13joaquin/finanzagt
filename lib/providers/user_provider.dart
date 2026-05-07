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
  bool get isAnonymous => _currentUser?.isAnonymous ?? true;

  UserProvider() {
    _listenToAuthChanges();
  }

  void _listenToAuthChanges() {
    _authSubscription = _authRepo.authStateChanges.listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        notifyListeners();

        try {
          debugPrint("Iniciando sesión anónima automáticamente...");
          await _authRepo.signInAnonymously();
        } catch (e) {
          debugPrint("Error en inicio silencioso: $e");
        }
      } else {
        await _loadOrCreateUserProfile(firebaseUser);
      }
    });
  }

  // --- LÓGICA DE SINCRONIZACIÓN REAL (La que repara el perfil) ---
  Future<void> _loadOrCreateUserProfile(User firebaseUser) async {
    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (!userDoc.exists) {
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
      } else {
        // Sincronizamos el estado isAnonymous con Firebase Auth para evitar el bug de la vista
        _currentUser = UserModel.fromFirestore(userDoc).copyWith(
          isAnonymous: firebaseUser.isAnonymous,
          email: firebaseUser.email,
        );

        // Si en la DB decía que era anónimo pero Firebase Auth dice que NO, actualizamos la DB
        if (userDoc.data()?['isAnonymous'] == true && !firebaseUser.isAnonymous) {
          await _firestore.collection('users').doc(firebaseUser.uid).update({
            'isAnonymous': false,
            'email': firebaseUser.email,
          });
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error al cargar perfil de usuario: $e");
    }
  }

  // --- TUS MÉTODOS RESTAURADOS ---

  Future<void> updateFinancialHealth({
    required double totalIncomes,
    required double totalExpenses,
    required double totalSavings,
  }) async {
    if (_currentUser == null) return;

    double newSafeBalance = totalIncomes - totalExpenses - totalSavings;

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'safe_balance': newSafeBalance,
        'net_worth': totalSavings,
      });

      _currentUser = _currentUser!.copyWith(
        safeToSpend: newSafeBalance,
        netWorth: totalSavings,
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Error al actualizar salud financiera: $e");
    }
  }

  Future<void> updateDisplayName(String newName) async {
    if (_currentUser == null) return;
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'displayName': newName,
      });

      _currentUser = _currentUser!.copyWith(displayName: newName);
      notifyListeners();
    } catch (e) {
      debugPrint("Error al actualizar nombre: $e");
      rethrow;
    }
  }

  // AQUÍ ESTÁ EL MÉTODO QUE FALTABA
  Future<void> completeUserProfile({
    required String name,
    required int age,
    required String currency,
  }) async {
    if (_currentUser == null) return;
    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'displayName': name,
        'age': age,
        'currency': currency,
        'profile_completed': true,
      });

      _currentUser = _currentUser!.copyWith(
        displayName: name,
        profileCompleted: true,
      );
      notifyListeners();
    } catch (e) {
      debugPrint("Error al completar perfil: $e");
      rethrow;
    }
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