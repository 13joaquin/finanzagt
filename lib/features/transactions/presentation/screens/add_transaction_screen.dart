// Archivo: lib/screens/transactions/add_transaction_screen.dart
import 'package:flutter/material.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/transaction_model.dart';
import '../../data/providers/transaction_provider.dart';



class AddTransactionScreen extends ConsumerStatefulWidget {
  final String? editDocId;
  final Map<String, dynamic>? editData;

  const AddTransactionScreen({super.key, this.editDocId, this.editData});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final CurrencyTextInputFormatter _amountFormatter = CurrencyTextInputFormatter.currency(symbol: '', decimalDigits: 2);

  bool _isExpense = true;
  String? _selectedCategory;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  // --- NUEVA VARIABLE ---
  bool _isFixedExpense = false; // Controla el Switch

  final List<String> _expenseCategories = ['Comida', 'Transporte', 'Vivienda', 'Ocio/Flexible'];
  final List<String> _incomeCategories = ['Salario', 'Ventas', 'Otros'];

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    final String amountText = _amountController.text.replaceAll(',', '');
    final double amount = double.tryParse(amountText) ?? 0;

    if (amount <= 0 || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, ingresa un monto y selecciona una categoría")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final type = _isExpense ? 'expense' : 'income';

      final newTransaction = TransactionModel(
        id: '',
        name: _noteController.text.isEmpty
            ? (_isExpense ? "Gasto sin nombre" : "Ingreso sin nombre")
            : _noteController.text,
        amount: amount,
        date: _selectedDate,
        type: type,
        category: _selectedCategory!,
        isFixed: _isExpense ? _isFixedExpense : false, // Solo aplica si es gasto
      );

      await ref.read(transactionProvider.notifier).addTransaction(newTransaction);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color activeColor = _isExpense ? Colors.redAccent : Colors.green;

    return Scaffold(
      appBar: AppBar(title: Text(widget.editDocId == null ? "Nuevo Registro" : "Editar Registro")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(child: _typeButton("Gasto", true, Colors.redAccent)),
                const SizedBox(width: 10),
                Expanded(child: _typeButton("Ingreso", false, Colors.green)),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _amountController,
              inputFormatters: [_amountFormatter],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: activeColor),
              decoration: const InputDecoration(hintText: "0.00", border: InputBorder.none),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text("Seleccionar Categoría"),
              items: (_isExpense ? _expenseCategories : _incomeCategories)
                  .map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v),
              decoration: InputDecoration(filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 15),

            // --- NUEVO: SELECTOR DE GASTO FIJO ---
            if (_isExpense) // Solo se muestra si el botón de "Gasto" está activo
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text("¿Es un gasto fijo?"),
                  subtitle: const Text("Ej. Alquiler, internet, luz", style: TextStyle(fontSize: 12)),
                  value: _isFixedExpense,
                  activeColor: Colors.redAccent,
                  onChanged: (bool value) {
                    setState(() {
                      _isFixedExpense = value;
                    });
                  },
                ),
              ),

            TextField(
              controller: _noteController,
              decoration: InputDecoration(hintText: "Nota / Descripción", filled: true, fillColor: Colors.grey[100], border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
            ),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('dd / MM / yyyy').format(_selectedDate)),
              onTap: () async {
                final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
                if (picked != null) setState(() => _selectedDate = picked);
              },
              tileColor: Colors.grey[100],
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: activeColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                onPressed: _isLoading ? null : _saveTransaction,
                child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Guardar Registro", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String label, bool isExpense, Color color) {
    bool isSelected = _isExpense == isExpense;
    return GestureDetector(
      onTap: () => setState(() {
        _isExpense = isExpense;
        _selectedCategory = null;
        if (!isExpense) _isFixedExpense = false; // Reset al cambiar a ingreso
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isSelected ? color : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
      ),
    );
  }
}