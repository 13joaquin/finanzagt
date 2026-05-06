// Archivo: lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final bool isAnonymous;
  final String? email;
  final String displayName;
  final double safeToSpend;
  final double netWorth;
  final Map<String, dynamic> preferences;
  final bool profileCompleted;

  UserModel({
    required this.uid,
    this.isAnonymous = true,
    this.email,
    required this.displayName,
    required this.safeToSpend,
    required this.netWorth,
    required this.preferences,
    this.profileCompleted = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      isAnonymous: data['isAnonymous'] ?? true,
      email: data['email'],
      // CORRECCIÓN: Busca 'displayName', si no existe busca 'name', y si tampoco, pone 'Invitado'
      displayName: data['displayName'] ?? data['name'] ?? 'Invitado',
      safeToSpend: (data['safe_balance'] ?? 0.0).toDouble(),
      netWorth: (data['net_worth'] ?? 0.0).toDouble(),
      preferences: data['preferences'] ?? {},
      profileCompleted: data['profile_completed'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isAnonymous': isAnonymous,
      'email': email,
      'displayName': displayName, // Guardamos siempre como displayName para estandarizar
      'safe_balance': safeToSpend,
      'net_worth': netWorth,
      'preferences': preferences,
      'profile_completed': profileCompleted,
    };
  }

  // --- MÉTODO COPYWITH ---
  UserModel copyWith({
    String? uid,
    bool? isAnonymous,
    String? email,
    String? displayName,
    double? safeToSpend,
    double? netWorth,
    Map<String, dynamic>? preferences,
    bool? profileCompleted,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      safeToSpend: safeToSpend ?? this.safeToSpend,
      netWorth: netWorth ?? this.netWorth,
      preferences: preferences ?? this.preferences,
      profileCompleted: profileCompleted ?? this.profileCompleted,
    );
  }
}