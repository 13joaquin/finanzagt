import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final String? editDocId;
  final Map<String, dynamic>? editData;

  const AddTransactionScreen({super.key, this.editDocId, this.editData});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final CurrencyTextInputFormatter _amountFormatter = CurrencyTextInputFormatter.currency(symbol: '', decimalDigits: 2);

  bool _isExpense = true;
  String? _selectedCategory;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  List<String> _expenseCategories = ['Comida', 'Transporte', 'Vivienda', 'Ocio/Flexible'];
  List<String> _incomeCategories = ['Salario', 'Ventas', 'Otros'];

  final TransactionRepository _transactionRepo = TransactionRepository();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserCategories();
    });

    if (widget.editDocId != null && widget.editData != null) {
      _isExpense = widget.editData!['type'] == 'expense';
      _selectedCategory = widget.editData!['category'];
      _noteController.text = widget.editData!['merchantName'] ?? widget.editData!['title'] ?? '';
      double amt = (widget.editData!['amount'] ?? 0).toDouble();
      _amountController.text = _amountFormatter.formatDouble(amt);
      if (widget.editData!['date'] != null) {
        _selectedDate = (widget.editData!['date'] as Timestamp).toDate();
      }
    }
  }

  Future<void> _loadUserCategories() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.currentUser?.uid;

    if (uid == null) return;

    try {
      final categories = await _transactionRepo.getUserCategories(uid);
      if (categories.isNotEmpty) {
        setState(() {
          _expenseCategories = categories.where((c) => c != 'Salario' && c != 'Ventas' && c != 'Otros').toList();
          _incomeCategories = categories.where((c) => c == 'Salario' || c == 'Ventas' || c == 'Otros').toList();
        });
      }
    } catch (e) {
      debugPrint("Error cargando categorías: $e");
    }
  }

  Future<void> _saveTransaction() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final uid = userProvider.currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Error: Usuario no identificado")));
      return;
    }

    if (_amountController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Por favor selecciona categoría y monto")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final double amount = _amountFormatter.getUnformattedValue().toDouble();

      // CORRECCIÓN: Usamos merchantName como lo exige el modelo
      final transaction = TransactionModel(
        id: widget.editDocId ?? '',
        merchantName: _noteController.text.isEmpty ? _selectedCategory! : _noteController.text,
        amount: amount,
        date: _selectedDate,
        category: _selectedCategory!,
        type: _isExpense ? 'expense' : 'income',
      );

      // CORRECCIÓN: Llamamos a addTransaction y updateTransaction que ahora sí existen
      if (widget.editDocId == null) {
        await _transactionRepo.addTransaction(uid, transaction);
      } else {
        await _transactionRepo.updateTransaction(uid, widget.editDocId!, transaction);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isExpense ? Colors.redAccent : Colors.green;
    return Scaffold(
      appBar: AppBar(title: Text(widget.editDocId == null ? "Nueva Transacción" : "Editar"), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
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
              keyboardType: TextInputType.number,
              inputFormatters: [_amountFormatter],
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: activeColor),
              decoration: const InputDecoration(hintText: '0.00', border: InputBorder.none),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: (_isExpense ? _expenseCategories : _incomeCategories).map((c) => ChoiceChip(
                label: Text(c),
                selected: _selectedCategory == c,
                onSelected: (s) => setState(() => _selectedCategory = c),
                selectedColor: activeColor.withOpacity(0.2),
              )).toList(),
            ),
            const SizedBox(height: 20),
            TextField(controller: _noteController, decoration: const InputDecoration(hintText: 'Descripción (Opcional)', prefixIcon: Icon(Icons.edit))),
            const SizedBox(height: 15),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
              onTap: () async {
                DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2000), lastDate: DateTime(2100));
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
      onTap: () => setState(() { _isExpense = isExpense; _selectedCategory = null; }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(color: isSelected ? color : Colors.grey[200], borderRadius: BorderRadius.circular(12)),
        child: Center(child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.bold))),
      ),
    );
  }
}