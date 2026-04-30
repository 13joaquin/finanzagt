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

  Future<void> _loadOrCreateUserProfile(User firebaseUser) async {
    try {
      final userDoc = await _firestore.collection('users').doc(firebaseUser.uid).get();

      if (userDoc.exists) {
        _currentUser = UserModel.fromFirestore(userDoc);
      } else {
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

  // --- NUEVO: GESTIÓN DE SALDO SEGURO (SAFE TO SPEND) ---

  /// Este método actualiza el saldo disponible restando gastos y ahorros.
  /// Se llama automáticamente desde la lógica de transacciones.
  Future<void> updateFinancialHealth({
    required double totalIncomes,
    required double totalExpenses,
    required double totalSavings,
  }) async {
    if (_currentUser == null) return;

    // Cálculo: Lo que entra menos lo que sale y lo que se guarda en "cubetas"
    double newSafeBalance = totalIncomes - totalExpenses - totalSavings;

    try {
      await _firestore.collection('users').doc(_currentUser!.uid).update({
        'safe_to_spend': newSafeBalance,
        // El Net Worth (Patrimonio) es diferente: es lo que tienes ahorrado
        'net_worth': totalSavings,
      });

      // Actualizamos localmente para que la UI reaccione de inmediato
      _currentUser = _currentUser!.copyWith(
        safeToSpend: newSafeBalance,
        netWorth: totalSavings,
      );

      notifyListeners();
    } catch (e) {
      debugPrint("Error al actualizar salud financiera: $e");
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

  Future<void> signOut() async {
    await _authRepo.signOut();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}