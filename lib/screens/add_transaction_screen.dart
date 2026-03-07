import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart'; // NUEVO

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _noteController = TextEditingController();

  // NUEVO: Formateador que agrega comas automáticamente (ej: 1,000.00)
  final CurrencyTextInputFormatter _amountFormatter = CurrencyTextInputFormatter.currency(
    symbol: '', // Sin símbolo aquí porque ya lo tenemos dibujado fuera del input
    decimalDigits: 2,
  );

  bool _isExpense = true;
  String _selectedCategory = 'Comida';
  bool _isLoading = false;

  final List<String> _expenseCategories = ['Comida', 'Transporte', 'Servicios', 'Ocio', 'Salud'];
  final List<String> _incomeCategories = ['Salario', 'Negocio', 'Inversión', 'Regalo', 'Otros'];

  Future<void> _saveTransaction() async {
    // Obtenemos el valor real sin comas para la base de datos
    double amount = _amountFormatter.getUnformattedValue().toDouble();
    if (amount <= 0) return;

    setState(() { _isLoading = true; });

    try {
      String note = _noteController.text.isEmpty ? _selectedCategory : _noteController.text;
      final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');
      final newTransactionRef = userRef.collection('transactions').doc();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) throw Exception("Usuario no encontrado.");

        double currentSafeBalance = (userSnapshot.data() as Map<String, dynamic>)['safe_balance'] ?? 0.0;
        double newSafeBalance = _isExpense ? (currentSafeBalance - amount) : (currentSafeBalance + amount);

        transaction.set(newTransactionRef, {
          'title': note,
          'category': _selectedCategory,
          'amount': amount,
          'is_expense': _isExpense,
          'date': FieldValue.serverTimestamp(),
        });

        transaction.update(userRef, {'safe_balance': newSafeBalance});
      });

      if (mounted) Navigator.pop(context);
    } catch (e) {
      debugPrint("Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fallo al guardar: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _isExpense ? Colors.redAccent : const Color(0xFF2E7D32);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(25), topRight: Radius.circular(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text('Nueva Transacción', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900])),
            const SizedBox(height: 20),

            // Selector Gasto / Ingreso
            Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() { _isExpense = true; _selectedCategory = _expenseCategories.first; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: _isExpense ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12), boxShadow: _isExpense ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : []),
                        child: Center(child: Text('Gasto', style: TextStyle(fontWeight: FontWeight.bold, color: _isExpense ? Colors.redAccent : Colors.grey))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() { _isExpense = false; _selectedCategory = _incomeCategories.first; }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(color: !_isExpense ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(12), boxShadow: !_isExpense ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : []),
                        child: Center(child: Text('Ingreso', style: TextStyle(fontWeight: FontWeight.bold, color: !_isExpense ? const Color(0xFF2E7D32) : Colors.grey))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input de Cantidad (AHORA CON FORMATO AUTOMÁTICO)
            Text('Monto (Q)', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Q ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: activeColor)),
                Expanded(
                  child: TextField(
                    inputFormatters: [_amountFormatter], // APLICA LAS COMAS AUTOMÁTICAS
                    keyboardType: TextInputType.number,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: activeColor),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      hintStyle: TextStyle(color: activeColor.withValues(alpha: 0.3)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 20),

            // Selector de Categorías
            Text('Categoría', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10, runSpacing: 10,
              children: (_isExpense ? _expenseCategories : _incomeCategories).map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: activeColor.withValues(alpha: 0.1),
                  labelStyle: TextStyle(color: isSelected ? activeColor : Colors.grey[700], fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? activeColor.withValues(alpha: 0.5) : Colors.transparent)),
                  onSelected: (selected) => setState(() => _selectedCategory = category),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Descripción
            TextField(
              controller: _noteController,
              decoration: InputDecoration(
                hintText: 'Descripción / Comercio...',
                prefixIcon: const Icon(Icons.notes, color: Colors.grey),
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const Spacer(),

            // Botón
            SizedBox(
              width: double.infinity, height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(backgroundColor: activeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Guardar Transacción', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}