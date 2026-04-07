import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class BudgetConfigScreen extends StatefulWidget {
  const BudgetConfigScreen({super.key});

  @override
  State<BudgetConfigScreen> createState() => _BudgetConfigScreenState();
}

class _BudgetConfigScreenState extends State<BudgetConfigScreen> {
  final TextEditingController _incomeController = TextEditingController();

  // Porcentajes estándar de la regla 50/30/20
  double needsPercentage = 0.50;
  double wantsPercentage = 0.30;
  double savingsPercentage = 0.20;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentBudget();
  }

  // Cargar datos actuales si existen
  Future<void> _loadCurrentBudget() async {
    final uid = Provider.of<UserProvider>(context, listen: false).currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      setState(() {
        _incomeController.text = (data['monthly_income'] ?? 0).toString();
      });
    }
  }

  Future<void> _saveBudget(String uid) async {
    final income = double.tryParse(_incomeController.text) ?? 0;
    if (income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingresa un sueldo válido")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Guardamos los límites calculados en el perfil del usuario
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'monthly_income': income,
        'limit_needs': income * needsPercentage,     // 50%
        'limit_wants': income * wantsPercentage,     // 30%
        'limit_savings': income * savingsPercentage, // 20%
        'last_budget_update': Timestamp.now(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("¡Presupuesto configurado con éxito!"), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error al guardar presupuesto: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = Provider.of<UserProvider>(context).currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Configurar Mi Mes", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Cuál es tu ingreso mensual?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _incomeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A47F6)),
              decoration: InputDecoration(
                prefixText: "Q ",
                hintText: "0.00",
                filled: true,
                fillColor: const Color(0xFFF5F7FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
              onChanged: (value) => setState(() {}), // Para actualizar los cálculos visuales
            ),
            const SizedBox(height: 30),
            const Text(
              "Distribución Sugerida (50/30/20)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildDistributionTile("Necesidades (50%)", _calculateAmount(0.50), Colors.blue, Icons.home),
            _buildDistributionTile("Deseos/Ocio (30%)", _calculateAmount(0.30), Colors.orange, Icons.confirmation_number_outlined),
            _buildDistributionTile("Ahorro/Metas (20%)", _calculateAmount(0.20), Colors.green, Icons.savings),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _saveBudget(uid),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A47F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Establecer Presupuesto", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAmount(double percentage) {
    final income = double.tryParse(_incomeController.text) ?? 0;
    return income * percentage;
  }

  Widget _buildDistributionTile(String title, double amount, Color color, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            "Q${amount.toStringAsFixed(2)}",
            style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16),
          ),
        ],
      ),
    );
  }
}