import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

// IMPORTACIONES DE TU ARQUITECTURA
import '../data/models/goal_model.dart';
import '../../sanctuary/data/repositories/goal_repository.dart';
import '../../../features/auth/presentation/providers/user_provider.dart';
// 1. IMPORTAMOS EL TRANSACTION PROVIDER PARA EL "DOBLE MOVIMIENTO"
import '../../transactions/data/providers/transaction_provider.dart';
import '../../transactions/models/transaction_model.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final GoalRepository _goalRepo = GoalRepository(); // Instanciamos el repo una vez

  // --- FUNCIONES CORREGIDAS CON EL ID REAL Y EL DOBLE MOVIMIENTO ---

  Future<void> _saveNewGoal(String uid, String title, double targetAmount) async {
    try {
      final newGoal = GoalModel(
        id: '',
        name: title,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        colorHex: '#4CAF50',
      );
      await _goalRepo.createGoal(uid, newGoal);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error creando meta: $e");
    }
  }

  Future<void> _updateGoal(String uid, String docId, String title, double targetAmount) async {
    try {
      await _goalRepo.updateGoal(uid, docId, {
        'name': title,
        'targetAmount': targetAmount,
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error actualizando meta: $e");
    }
  }

  Future<void> _deleteGoal(String uid, String docId) async {
    try {
      await _goalRepo.deleteGoal(uid, docId);
    } catch (e) {
      debugPrint("Error eliminando meta: $e");
    }
  }

  // EL DOBLE MOVIMIENTO: Ahorrar en la meta + Registrar el "gasto" (ahorro) en el Dashboard
  Future<void> _addMoney(String uid, String docId, String title, double amount, TransactionProvider txProvider) async {
    try {
      // Movimiento 1: Aumentar el dinero en la cubeta (Meta)
      await _goalRepo.addFundsToGoal(uid, docId, amount);

      // Creamos el "Paquete" (TransactionModel) con todos los campos obligatorios
      final nuevaTransaccion = TransactionModel(
        id: '', // Lo dejamos vacío porque Firebase generará el ID
        name: 'Ahorro: $title',
        amount: amount,
        date: DateTime.now(), // Agregamos la fecha actual
        type: 'expense', // Lo registramos como gasto para que lo reste del Dashboard
        category: 'Ahorro/Metas',
      );

      // Movimiento 2: Enviamos el paquete completo como un único argumento
      await txProvider.addTransaction(nuevaTransaccion);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error abonando: $e");
    }
  }

  Future<void> _spendMoney(String uid, String docId, double amount) async {
    try {
      // Al gastar de una meta, solo restamos de la cubeta (el dinero ya salió del flujo general antes)
      await _goalRepo.spendFundsFromGoal(uid, docId, amount);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error gastando de la meta: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // 3. OBTENEMOS LOS PROVIDERS
    final userProvider = Provider.of<UserProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context, listen: false); // Escuchamos al jefe de transacciones
    final currentUser = userProvider.currentUser;

    if (currentUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final String uid = currentUser.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Santuario (Ahorros)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 4. STREAM DINÁMICO CON EL UID REAL
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('presentation')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Algo salió mal'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final goals = snapshot.data!.docs;

          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  const Text("Aún no tienes metas de ahorro", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final doc = goals[index];
              final data = doc.data() as Map<String, dynamic>;
              final title = data['name'] ?? 'Meta'; // Obtenemos el título

              return _buildGoalCard(
                uid: uid,
                docId: doc.id,
                title: title,
                current: (data['currentAmount'] ?? 0).toDouble(),
                target: (data['targetAmount'] ?? 0).toDouble(),
                color: const Color(0xFF2E7D32),
                txProvider: transactionProvider, // Pasamos el provider a la tarjeta
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showGoalFormModal(uid: uid),
        label: const Text('Nueva Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color(0xFF2E7D32),
      ),
    );
  }

  // --- MODALES Y UI ---

  void _showGoalFormModal({required String uid, String? docId, String? currentTitle, double? currentTarget}) {
    if (docId != null) {
      _titleController.text = currentTitle ?? '';
      _amountController.text = currentTarget?.toStringAsFixed(0) ?? '';
    } else {
      _titleController.clear();
      _amountController.clear();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(docId == null ? 'Nueva Meta' : 'Editar Meta', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Nombre de la meta (ej. Viaje)')),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto objetivo (Q)')),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  final title = _titleController.text;
                  final amt = double.tryParse(_amountController.text) ?? 0;
                  if (docId == null) {
                    _saveNewGoal(uid, title, amt);
                  } else {
                    _updateGoal(uid, docId, title, amt);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('Guardar Meta', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard({
    required String uid,
    required String docId,
    required String title,
    required double current,
    required double target,
    required Color color,
    required TransactionProvider txProvider, // Recibimos el provider
  }) {
    double progress = (current / target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => _deleteGoal(uid, docId), icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Q${current.toStringAsFixed(2)}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text('Meta: Q${target.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showMoneyModal(uid, docId, title, true, txProvider), // Pasamos true para Abonar
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Abonar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showMoneyModal(uid, docId, title, false, txProvider), // Pasamos false para Gastar
                  icon: const Icon(Icons.shopping_bag_outlined, size: 18, color: Colors.orange),
                  label: const Text('Gastar', style: TextStyle(color: Colors.orange)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange.withOpacity(0.1), elevation: 0),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Modal unificado para Abonar o Gastar
  void _showMoneyModal(String uid, String docId, String title, bool isAdding, TransactionProvider txProvider) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${isAdding ? "Abonar a" : "Gastar de"}: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Monto (Q)')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final amt = double.tryParse(_amountController.text) ?? 0;
                if (isAdding) {
                  _addMoney(uid, docId, title, amt, txProvider); // Doble movimiento
                } else {
                  _spendMoney(uid, docId, amt); // Solo gasta de la meta
                }
              },
              child: const Text('Confirmar'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}