import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:intl/intl.dart';
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
  final TextEditingController _amountController = TextEditingController(); // Controlador separado para el monto
  final CurrencyTextInputFormatter _amountFormatter = CurrencyTextInputFormatter.currency(symbol: '', decimalDigits: 2);

  bool _isExpense = true;
  String? _selectedCategory;
  bool _isLoading = false;
  DateTime _selectedDate = DateTime.now();

  List<String> _expenseCategories = ['Comida', 'Transporte', 'Vivienda'];
  List<String> _incomeCategories = ['Salario', 'Ventas', 'Otros'];

  @override
  void initState() {
    super.initState();
    _loadUserCategories();

    if (widget.editDocId != null && widget.editData != null) {
      _isExpense = widget.editData!['is_expense'];
      _selectedCategory = widget.editData!['category'];
      _noteController.text = widget.editData!['title'];

      // SOLUCIÓN AL ERROR: Formateamos el monto inicial y lo ponemos en el controlador
      double initialAmount = (widget.editData!['amount'] ?? 0).toDouble();
      _amountController.text = _amountFormatter.formatDouble(initialAmount);

      _selectedDate = (widget.editData!['date'] as Timestamp).toDate();
    }
  }

  Future<void> _loadUserCategories() async {
    var snapshot = await FirebaseFirestore.instance.collection('users').doc('test_user_123').get();
    if (snapshot.exists) {
      var data = snapshot.data()!;
      setState(() {
        _expenseCategories = List<String>.from(data['expense_categories'] ?? _expenseCategories);
        _incomeCategories = List<String>.from(data['income_categories'] ?? _incomeCategories);
        if (_selectedCategory == null) {
          _selectedCategory = _isExpense ? _expenseCategories.first : _incomeCategories.first;
        }
      });
    }
  }

  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveTransaction() async {
    double amount = double.tryParse(_amountFormatter.getUnformattedValue().toString()) ?? 0.0;

    // Validaciones básicas
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ingresa un monto válido')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una categoría')));
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // A. Instanciamos nuestro repositorio (El "Cerebro")
      final repository = TransactionRepository();

      // B. Empaquetamos los datos visuales en nuestro Modelo estructurado
      final newTransaction = TransactionModel(
        id: '', // El repositorio se encargará de asignarle el ID de Firebase
        amount: amount,
        type: _isExpense ? 'expense' : 'income',
        category: _selectedCategory!,
        merchantName: _noteController.text.isEmpty ? 'General' : _noteController.text,
        date: _selectedDate,
      );

      // C. ¡Le pasamos el paquete al Repositorio y él hace toda la magia!
      await repository.addTransaction('test_user_123', newTransaction);

      if (mounted) {
        Navigator.pop(context); // Cerramos el modal al terminar
      }
    } catch (e) {
      debugPrint("Error al guardar: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al procesar la transacción')));
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isExpense ? Colors.redAccent : const Color(0xFF2E7D32);

    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.editDocId != null ? 'Editar' : 'Nuevo', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // Switch Gasto/Ingreso
          Row(
            children: [
              Expanded(child: ChoiceChip(label: const Text("Gasto"), selected: _isExpense, onSelected: (s) => setState(() => _isExpense = true))),
              const SizedBox(width: 10),
              Expanded(child: ChoiceChip(label: const Text("Ingreso"), selected: !_isExpense, onSelected: (s) => setState(() => _isExpense = false))),
            ],
          ),
          const SizedBox(height: 20),
          // Monto con el formateador corregido
          TextField(
            controller: _amountController,
            inputFormatters: [_amountFormatter],
            keyboardType: TextInputType.number,
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: activeColor),
            decoration: const InputDecoration(prefixText: 'Q ', border: InputBorder.none),
          ),
          const SizedBox(height: 10),
          // Categorías dinámicas
          Wrap(
            spacing: 8,
            children: (_isExpense ? _expenseCategories : _incomeCategories).map((c) => ChoiceChip(
              label: Text(c),
              selected: _selectedCategory == c,
              onSelected: (s) => setState(() => _selectedCategory = c),
            )).toList(),
          ),
          const SizedBox(height: 20),
          TextField(controller: _noteController, decoration: const InputDecoration(hintText: 'Descripción', prefixIcon: Icon(Icons.edit))),
          const SizedBox(height: 15),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
            onTap: _pickDate,
            tileColor: Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: activeColor),
              onPressed: _isLoading ? null : _saveTransaction,
              child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}