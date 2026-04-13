// Archivo: lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final bool isAnonymous;
  final String? email;
  final String displayName;
  final double safeToSpend;
  final double netWorth;
  final String subscriptionStatus;
  final Map<String, dynamic> preferences;
  // --- NUEVOS CAMPOS ---
  final bool profileCompleted;
  final String currency;

  UserModel({
    required this.uid,
    this.isAnonymous = true,
    this.email,
    required this.displayName,
    required this.safeToSpend,
    required this.netWorth,
    this.subscriptionStatus = 'free',
    required this.preferences,
    this.profileCompleted = false, // Por defecto falso
    this.currency = 'Q',           // Por defecto Quetzales
  });

  // Fábrica para leer de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      isAnonymous: data['isAnonymous'] ?? true,
      email: data['email'],
      displayName: data['displayName'] ?? 'Usuario',
      safeToSpend: (data['safe_balance'] ?? 0.0).toDouble(),
      netWorth: (data['net_worth'] ?? 0.0).toDouble(),
      subscriptionStatus: data['subscriptionStatus'] ?? 'free',
      preferences: data['preferences'] ?? {
        'currency': 'GTQ',
        'budgetModel': 'simplified',
      },
      // Leemos los nuevos campos (con valores por defecto por si el documento es viejo)
      profileCompleted: data['profile_completed'] ?? false,
      currency: data['currency'] ?? (data['preferences']?['currency'] ?? 'Q'),
    );
  }

  // Convertir a formato de Firebase para guardar
  Map<String, dynamic> toFirestore() {
    return {
      'isAnonymous': isAnonymous,
      'email': email,
      'displayName': displayName,
      'safe_balance': safeToSpend,
      'net_worth': netWorth,
      'subscriptionStatus': subscriptionStatus,
      'preferences': preferences,
      // Guardamos los nuevos campos
      'profile_completed': profileCompleted,
      'currency': currency,
    };
  }
}