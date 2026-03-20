// Archivo: lib/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final bool isAnonymous;
  final String? email;
  final String displayName;
  final double safeToSpend; // En nuestro MVP: safe_balance
  final double netWorth;    // En nuestro MVP: net_worth
  final String subscriptionStatus;
  final Map<String, dynamic> preferences;

  UserModel({
    required this.uid,
    this.isAnonymous = true,
    this.email,
    required this.displayName,
    required this.safeToSpend,
    required this.netWorth,
    this.subscriptionStatus = 'free',
    required this.preferences,
  });

  // Fábrica para leer de Firestore
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

    return UserModel(
      uid: doc.id,
      isAnonymous: data['isAnonymous'] ?? true,
      email: data['email'],
      displayName: data['displayName'] ?? 'Usuario',
      safeToSpend: (data['safe_balance'] ?? 0.0).toDouble(), // Conectado al MVP actual
      netWorth: (data['net_worth'] ?? 0.0).toDouble(),       // Conectado al MVP actual
      subscriptionStatus: data['subscriptionStatus'] ?? 'free',
      preferences: data['preferences'] ?? {
        'currency': 'GTQ',
        'budgetModel': 'simplified', // El modelo de 3 cubetas que implementamos
      },
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
    };
  }
}