// Archivo: lib/screens/sanctuary/sanctuary_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart'; // <-- IMPORTANTE: Paquete de animaciones

import '../../providers/user_provider.dart';
import '../../providers/sanctuary_provider.dart'; // <-- IMPORTANTE: Nuestro nuevo cerebro

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

  // Función auxiliar para traducir el estado del árbol a un texto amigable
  String _getStageDescription(TreeStage stage) {
    switch (stage) {
      case TreeStage.seed:
        return "Una semilla esperando crecer...";
      case TreeStage.sprout:
        return "¡Un pequeño brote! Vas por buen camino.";
      case TreeStage.youngTree:
        return "Tu árbol joven se está fortaleciendo.";
      case TreeStage.fullTree:
        return "Un árbol fuerte y frondoso.";
      case TreeStage.blooming:
        return "¡Floreciendo! Has cumplido tus metas.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFE8F5E9),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Santuario',
          style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc(currentUser.uid).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)));
            }

            var userData = snapshot.data?.data() as Map<String, dynamic>? ?? {};
            double netWorth = (userData['net_worth'] ?? 0.0).toDouble();

            // AQUÍ CONECTAMOS LA PANTALLA CON EL CEREBRO DEL SANTUARIO
            return Consumer<SanctuaryProvider>(
                builder: (context, sanctuary, child) {
                  return Center(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // --- 1. TU NUEVO ÁRBOL ANIMADO ---
                          SizedBox(
                            height: 250, // Le damos un buen tamaño a la animación
                            child: Lottie.asset(
                              'assets/animations/tree_growth_without_background.json',
                              fit: BoxFit.contain,
                              // repeat: false, // Descomenta esto si no quieres que la animación se repita en bucle
                            ),
                          ),

                          const SizedBox(height: 20),

                          // --- 2. TEXTO DINÁMICO SEGÚN EL ESTADO ---
                          Text(
                            _getStageDescription(sanctuary.treeStage),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40),
                            child: Text(
                              'Este árbol representa tu patrimonio. Sigue ahorrando y gastando con sabiduría para verlo crecer.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.green[800], fontSize: 14),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // --- 3. PATRIMONIO REAL ---
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'PATRIMONIO NETO',
                                  style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  'Q${netWorth.toStringAsFixed(2)}',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),

                          // --- 4. BOTONES DE SIMULACIÓN (SOLO PARA PRUEBAS) ---
                          const Divider(indent: 40, endIndent: 40),
                          const Text("SIMULADOR (Modo Desarrollo)", style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // Simulamos que el usuario acaba de empezar (0%)
                                  sanctuary.updateSanctuary(
                                      activeGoals: [{'target': 1000, 'saved': 0}],
                                      totalIncome: 1000,
                                      totalExpenses: 500
                                  );
                                },
                                child: const Text("Semilla"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Simulamos que el usuario va por la mitad (50%)
                                  sanctuary.updateSanctuary(
                                      activeGoals: [{'target': 1000, 'saved': 500}],
                                      totalIncome: 1000,
                                      totalExpenses: 500
                                  );
                                },
                                child: const Text("Mitad"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // Simulamos que el usuario cumplió la meta (100%)
                                  sanctuary.updateSanctuary(
                                      activeGoals: [{'target': 1000, 'saved': 1000}],
                                      totalIncome: 1000,
                                      totalExpenses: 500
                                  );
                                },
                                child: const Text("Meta Cumplida"),
                              ),
                            ],
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  );
                }
            );
          }
      ),
    );
  }
}