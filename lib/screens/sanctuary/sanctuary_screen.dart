import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9), // Verde muy suave
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0, automaticallyImplyLeading: false),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            var userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            double netWorth = (userData['net_worth'] ?? 0.0).toDouble();

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.eco_rounded, size: 100, color: Color(0xFF2E7D32)),
                  const SizedBox(height: 20),
                  const Text('Tu Santuario Financiero', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20))),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text('Este árbol representa tu patrimonio. Sigue ahorrando y gastando con sabiduría para verlo crecer.', textAlign: TextAlign.center, style: TextStyle(color: Colors.green[800], fontSize: 14)),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                    child: Column(
                      children: [
                        const Text('PATRIMONIO NETO', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text('Q${netWorth.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // Espacio para el menú inferior
                ],
              ),
            );
          }
      ),
    );
  }
}