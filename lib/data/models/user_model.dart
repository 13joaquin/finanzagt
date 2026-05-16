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

  // NUEVO: Campo para la configuración regional (Moneda)
  final String? currency;

  UserModel({
    required this.uid,
    this.isAnonymous = true,
    this.email,
    required this.displayName,
    required this.safeToSpend,
    required this.netWorth,
    required this.preferences,
    this.profileCompleted = false,
    this.currency, // Lo añadimos al constructor
  });
// NUEVO: El "interruptor" inteligente del Plan Maestro 2.0
  // Si NO es anónimo, entonces es usuario Pro (Registrado).
  bool get isPro => !isAnonymous;

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
      // NUEVO: Leemos la moneda desde Firebase (si no existe, queda nulo)
      currency: data['currency'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'isAnonymous': isAnonymous,
      'email': email,
      'displayName': displayName,
      'safe_balance': safeToSpend,
      'net_worth': netWorth,
      'preferences': preferences,
      'profile_completed': profileCompleted,
      // NUEVO: Guardamos la moneda en Firebase
      'currency': currency,
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
    String? currency, // Lo añadimos aquí
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
      currency: currency ?? this.currency, // Y lo actualizamos aquí
    );
  }
}