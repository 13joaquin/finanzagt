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
  final String? currency;
  final bool isPro;

  UserModel({
    required this.uid,
    this.isAnonymous = true,
    this.email,
    required this.displayName,
    required this.safeToSpend,
    required this.netWorth,
    required this.preferences,
    this.profileCompleted = false,
    this.currency,
    this.isPro = false,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    // Aseguramos que la data se maneje como un mapa de objetos dinámicos
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      isAnonymous: data['isAnonymous'] as bool? ?? true,
      // CORRECCIÓN: Casteo explícito a String? para evitar el error de Object?
      email: data['email'] as String?,
      displayName: data['displayName'] as String? ?? data['name'] as String? ?? 'Invitado',
      safeToSpend: (data['safe_balance'] ?? 0.0).toDouble(),
      netWorth: (data['net_worth'] ?? 0.0).toDouble(),
      // CORRECCIÓN: Casteo explícito del mapa de preferencias
      preferences: data['preferences'] as Map<String, dynamic>? ?? {},
      profileCompleted: data['profile_completed'] as bool? ?? false,
      // CORRECCIÓN: Casteo explícito de la moneda para evitar el error de Object?
      currency: data['currency'] as String?,
      isPro: data['isPro'] as bool? ?? false,
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
      // CORRECCIÓN: Usando el nombre correcto de la variable (camelCase)
      'profile_completed': profileCompleted,
      'currency': currency,
      'isPro': isPro,
    };
  }

  UserModel copyWith({
    String? uid,
    bool? isAnonymous,
    String? email,
    String? displayName,
    double? safeToSpend,
    double? netWorth,
    Map<String, dynamic>? preferences,
    bool? profileCompleted,
    String? currency,
    bool? isPro,
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
      currency: currency ?? this.currency,
      isPro: isPro ?? this.isPro,
    );
  }
}