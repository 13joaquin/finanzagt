import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _currentUser;

  // Variable pública para que las pantallas lean el usuario
  UserModel? get currentUser => _currentUser;

  // Esta función se conecta a Firebase y se queda escuchando (Stream)
  void listenToUserChanges(String uid) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .listen((DocumentSnapshot snapshot) {
      if (snapshot.exists) {
        // Convertimos los datos de Firebase a nuestro Modelo estructurado
        _currentUser = UserModel.fromFirestore(snapshot);

        // ¡LA MAGIA DE PROVIDER!
        // Esto le avisa a cualquier pantalla conectada que redibuje los saldos.
        notifyListeners();
      }
    });
  }
}