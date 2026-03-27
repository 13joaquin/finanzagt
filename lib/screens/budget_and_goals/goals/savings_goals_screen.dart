import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORTACIONES DE TU NUEVA ARQUITECTURA:
import '../../../data/models/goal_model.dart';
import '../../../data/repositories/goal_repository.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  // ==========================================
  // FUNCIONES LIMPIAS (Llaman al Repositorio)
  // ==========================================

  // A. Guardar Nueva Meta (Limpia)
  Future<void> _saveNewGoal(String title, double targetAmount) async {
    try {
      final repository = GoalRepository();

      final newGoal = GoalModel(
        id: '', // Firebase le asignará el ID
        name: title,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        colorHex: '#4CAF50', // Color verde por defecto
      );

      await repository.createGoal('test_user_123', newGoal);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error creando meta: $e");
    }
  }

  // B. Abonar Dinero (Limpia)
  Future<void> _addMoney(String goalId, double amount) async {
    try {
      final repository = GoalRepository();
      await repository.addFundsToGoal('test_user_123', goalId, amount);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error abonando a la meta: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Verifica tu Saldo Seguro.')));
      }
    }
  }

  // C. Gastar Dinero (Limpia)
  Future<void> _spendMoney(String goalId, double amount, String reason) async {
    try {
      final repository = GoalRepository();
      await repository.spendFromGoal('test_user_123', goalId, amount, reason);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error gastando de la meta: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Supera lo ahorrado.')));
      }
    }
  }

  // ==========================================
  // MODALES (INTERFAZ VISUAL)
  // ==========================================

  void _showGoalFormModal({String? docId, String? currentTitle, double? currentTarget}) {
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
            Text(docId == null ? 'Crear Nuevo Objetivo' : 'Editar Objetivo', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: _titleController, decoration: InputDecoration(labelText: 'Nombre de la Meta (Ej. Viaje)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 15),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Monto Objetivo (Q)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: () async {
                  if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;
                  double target = double.parse(_amountController.text);

                  if (docId == null) {
                    // LLAMAMOS A LA FUNCIÓN LIMPIA A QUE CREAMOS ARRIBA
                    await _saveNewGoal(_titleController.text, target);
                  } else {
                    // Editar (Se mantiene usando Firestore directo hasta que hagamos el update en el Repo)
                    await FirebaseFirestore.instance.collection('users').doc('test_user_123').collection('goals').doc(docId).update({
                      'title': _titleController.text,
                      'target_amount': target,
                    });
                    if (mounted) Navigator.pop(context);
                  }
                },
                child: Text(docId == null ? 'Guardar Meta' : 'Actualizar Meta', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showAddMoneyModal(String docId, String title) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Abonar a $title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('El dinero se descontará de tu Saldo Seguro para Gastar.', style: TextStyle(color: Colors.grey, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Monto a transferir (Q)', prefixIcon: const Icon(Icons.attach_money), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                onPressed: () async {
                  double amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount <= 0) return;

                  // LLAMAMOS A LA FUNCIÓN LIMPIA B QUE CREAMOS ARRIBA
                  await _addMoney(docId, amount);
                },
                child: const Text('Confirmar Abono', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSpendMoneyModal(String docId, String title) {
    _amountController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Gastar de $title', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text('Esto reducirá el progreso de tu meta y tu Patrimonio Neto.', style: TextStyle(color: Colors.redAccent, fontSize: 13), textAlign: TextAlign.center),
            const SizedBox(height: 20),
            TextField(controller: _amountController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Monto a gastar (Q)', prefixIcon: const Icon(Icons.shopping_bag_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () async {
                  double amount = double.tryParse(_amountController.text) ?? 0;
                  if (amount <= 0) return;

                  // LLAMAMOS A LA FUNCIÓN LIMPIA C QUE CREAMOS ARRIBA
                  await _spendMoney(docId, amount, 'Compra para $title');
                },
                child: const Text('Confirmar Gasto', style: TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteGoal(String docId, double savedAmount) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');
    await FirebaseFirestore.instance.runTransaction((tx) async {
      var userSnap = await tx.get(userRef);
      double safeBalance = (userSnap.data() as Map<String, dynamic>)['safe_balance'] ?? 0.0;

      // Devolvemos el dinero al Saldo Seguro
      tx.update(userRef, {'safe_balance': safeBalance + savedAmount});
      tx.delete(userRef.collection('goals').doc(docId));
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color greenColor = const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Ahorro y Metas', style: TextStyle(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, foregroundColor: Colors.blueGrey[900], elevation: 0),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').collection('goals').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

            List<QueryDocumentSnapshot> goals = snapshot.hasData ? snapshot.data!.docs : [];

            // Calculamos el total ahorrado en vivo
            double totalSaved = 0;
            for (var doc in goals) {
              totalSaved += ((doc.data() as Map<String, dynamic>)['saved_amount'] ?? 0).toDouble();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TARJETA AHORRO TOTAL
                  Container(
                    width: double.infinity, padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: greenColor, borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      children: [
                        const Text('AHORRO TOTAL', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Q${totalSaved.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // MIS OBJETIVOS Y BOTÓN AGREGAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Mis Objetivos', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
                      TextButton.icon(
                        onPressed: () => _showGoalFormModal(),
                        icon: Icon(Icons.add_circle, color: greenColor),
                        label: Text('Agregar nuevo', style: TextStyle(color: greenColor, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  // LISTA DE 1 COLUMNA INFINITA
                  if (goals.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(40.0), child: Text("No tienes metas creadas", style: TextStyle(color: Colors.grey))))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: goals.length,
                      itemBuilder: (context, index) {
                        var doc = goals[index];
                        var data = doc.data() as Map<String, dynamic>;

                        String title = data['title'] ?? 'Sin título';
                        double target = (data['target_amount'] ?? 0).toDouble();
                        double saved = (data['saved_amount'] ?? 0).toDouble();

                        return _buildSingleColumnGoalCard(
                          docId: doc.id,
                          title: title,
                          saved: saved,
                          target: target,
                          color: Colors.blue, // Puedes hacerlo dinámico después
                        );
                      },
                    ),
                ],
              ),
            );
          }
      ),
    );
  }

  // WIDGET DE 1 COLUMNA (Con todos los botones funcionales)
  Widget _buildSingleColumnGoalCard({required String docId, required String title, required double saved, required double target, required Color color}) {
    double progress = target > 0 ? (saved / target) : 0;
    if (progress > 1.0) progress = 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(Icons.flag_rounded, color: color)),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Meta: Q${target.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              // MENÚ DE 3 PUNTOS
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.grey),
                onSelected: (value) {
                  if (value == 'edit') _showGoalFormModal(docId: docId, currentTitle: title, currentTarget: target);
                  if (value == 'delete') _deleteGoal(docId, saved);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 18), SizedBox(width: 10), Text('Editar')])),
                  const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 18, color: Colors.red), SizedBox(width: 10), Text('Eliminar y devolver dinero', style: TextStyle(color: Colors.red, fontSize: 12))])),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Q${saved.toStringAsFixed(0)}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(value: progress, backgroundColor: Colors.grey[200], valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 8, borderRadius: BorderRadius.circular(10)),
          const SizedBox(height: 15),

          // BOTONES DE ACCIÓN: ABONAR (+) Y GASTAR (-)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showAddMoneyModal(docId, title),
                  icon: const Icon(Icons.add, size: 18, color: Colors.white),
                  label: const Text('Abonar', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(backgroundColor: color, elevation: 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showSpendMoneyModal(docId, title),
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
}