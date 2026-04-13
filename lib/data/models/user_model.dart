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
  // AGREGAR ESTA LÍNEA:
  final bool profileCompleted;

  UserModel({
    required this.uid,
    this.isAnonymous = true,
    this.email,
    required this.displayName,
    required this.safeToSpend,
    required this.netWorth,
    required this.preferences,
    this.profileCompleted = false, // Por defecto falso
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      isAnonymous: data['isAnonymous'] ?? true,
      email: data['email'],
      displayName: data['displayName'] ?? 'Usuario',
      safeToSpend: (data['safe_balance'] ?? 0.0).toDouble(),
      netWorth: (data['net_worth'] ?? 0.0).toDouble(),
      preferences: data['preferences'] ?? {},
      // LEER DEL FIRESTORE:
      profileCompleted: data['profile_completed'] ?? false,
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
      'profile_completed': profileCompleted, // GUARDAR EN FIRESTORE
    };
  }
}