import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';


final userProvider = NotifierProvider<UserProvider, UserModel?>(
  UserProvider.new,
);

class UserProvider extends Notifier<UserModel?> {
  final AuthRepository _authRepo = AuthRepository();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription<User?>? _authSubscription;

  UserModel? get currentUser => state;
  bool get isAuthenticated => state != null;
  bool get isAnonymous => state?.isAnonymous ?? true;
  bool get isPro => state?.isPro ?? false;

  @override
  UserModel? build() {
    ref.onDispose(() {
      _authSubscription?.cancel();
    });

    _listenToAuthChanges();
    return null;
  }

  void _listenToAuthChanges() {
    _authSubscription = _authRepo.authStateChanges.listen(
          (User? firebaseUser) async {
        if (firebaseUser == null) {
          state = null;
          debugPrint(
            'Estado: Sin sesión. Esperando decisión del usuario en WelcomeScreen.',
          );
        } else {
          await _loadOrCreateUserProfile(firebaseUser);
        }
      },
    );
  }

  Future<void> fetchUser(String uid) async {
    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();

      if (userDoc.exists) {
        state = UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      debugPrint('Error al hacer fetchUser: $e');
    }
  }

  Future<void> _loadOrCreateUserProfile(User firebaseUser) async {
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (!userDoc.exists) {
        state = UserModel(
          uid: firebaseUser.uid,
          isAnonymous: firebaseUser.isAnonymous,
          displayName: firebaseUser.isAnonymous ? 'Invitado' : 'Usuario',
          email: firebaseUser.email,
          safeToSpend: 0.0,
          netWorth: 0.0,
          preferences: {},
          profileCompleted: false,
          currency: null,
          isPro: false,
        );

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(state!.toFirestore());
      } else {
        state = UserModel.fromFirestore(userDoc).copyWith(
          isAnonymous: firebaseUser.isAnonymous,
          email: firebaseUser.email,
        );

        if (userDoc.data()?['isAnonymous'] == true &&
            !firebaseUser.isAnonymous) {
          await _firestore.collection('users').doc(firebaseUser.uid).update({
            'isAnonymous': false,
            'email': firebaseUser.email,
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar perfil de usuario: $e');
    }
  }

  Future<void> updateProStatus(bool status) async {
    if (state == null) return;

    try {
      await _firestore.collection('users').doc(state!.uid).update({
        'isPro': status,
      });

      state = state!.copyWith(isPro: status);
    } catch (e) {
      debugPrint('Error al actualizar estado Pro: $e');
      rethrow;
    }
  }

  Future<void> updateFinancialHealth({
    required double totalIncomes,
    required double totalExpenses,
    required double totalSavings,
  }) async {
    if (state == null) return;

    final newSafeBalance = totalIncomes - totalExpenses - totalSavings;

    try {
      await _firestore.collection('users').doc(state!.uid).update({
        'safe_balance': newSafeBalance,
        'net_worth': totalSavings,
      });

      state = state!.copyWith(
        safeToSpend: newSafeBalance,
        netWorth: totalSavings,
      );
    } catch (e) {
      debugPrint('Error al actualizar salud financiera: $e');
    }
  }

  Future<void> updateDisplayName(String newName) async {
    if (state == null) return;

    try {
      await _firestore.collection('users').doc(state!.uid).update({
        'displayName': newName,
      });

      state = state!.copyWith(displayName: newName);
    } catch (e) {
      debugPrint('Error al actualizar nombre: $e');
      rethrow;
    }
  }

  Future<void> completeUserProfile({
    required String name,
    required int age,
    required String currency,
  }) async {
    if (state == null) return;

    try {
      await _firestore.collection('users').doc(state!.uid).update({
        'displayName': name,
        'age': age,
        'currency': currency,
        'profile_completed': true,
      });

      state = state!.copyWith(
        displayName: name,
        currency: currency,
        profileCompleted: true,
      );
    } catch (e) {
      debugPrint('Error al completar perfil: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authRepo.signOut();
  }
}

