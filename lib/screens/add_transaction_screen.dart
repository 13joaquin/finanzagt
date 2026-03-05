import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // IMPORTANTE AÑADIR ESTO

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Controladores para capturar lo que el usuario escribe
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  bool _isExpense = true;
  String _selectedCategory = 'Comida';
  bool _isLoading = false; // Para mostrar un circulo de carga al guardar

  final List<String> _expenseCategories = ['Comida', 'Transporte', 'Servicios', 'Ocio', 'Salud'];
  final List<String> _incomeCategories = ['Salario', 'Negocio', 'Inversión', 'Regalo', 'Otros'];

  // --- LÓGICA CORE DE FINANZAS ---
  Future<void> _saveTransaction() async {
    // 1. Validar que no esté vacío
    if (_amountController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Convertir el texto a número decimal
      double amount = double.parse(_amountController.text.replaceAll(',', '.'));
      String note = _noteController.text.isEmpty ? _selectedCategory : _noteController.text;

      // 3. Referencias a Firebase
      final userRef = FirebaseFirestore.instance.collection('users').doc('test_user_123');
      final newTransactionRef = userRef.collection('transactions').doc(); // Genera un ID único

      // 4. Ejecutar la transacción en Firestore (Garantiza que el saldo y el registro se guarden juntos)
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        // Leer el saldo actual
        DocumentSnapshot userSnapshot = await transaction.get(userRef);
        if (!userSnapshot.exists) {
          throw Exception("El usuario no existe");
        }

        double currentSafeBalance = (userSnapshot.data() as Map<String, dynamic>)['safe_balance'] ?? 0.0;

        // Calcular el nuevo saldo
        double newSafeBalance = _isExpense ? (currentSafeBalance - amount) : (currentSafeBalance + amount);

        // Guardar el recibo en la lista de transacciones
        transaction.set(newTransactionRef, {
          'title': note, // Usamos la nota o la categoría como título
          'category': _selectedCategory,
          'amount': amount,
          'is_expense': _isExpense,
          'date': FieldValue.serverTimestamp(), // Fecha y hora exacta del servidor
        });

        // Actualizar el saldo total del usuario
        transaction.update(userRef, {'safe_balance': newSafeBalance});
      });

      // 5. Cerrar la pantalla si todo salió bien
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint("Error guardando transacción: $e");
      // Aquí se podría mostrar un SnackBar (alerta) de error en el futuro
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Limpiar memoria
    _amountController.dispose();
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
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
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
                      onTap: () => setState(() {
                        _isExpense = true;
                        _selectedCategory = _expenseCategories.first;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isExpense ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: _isExpense ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : [],
                        ),
                        child: Center(child: Text('Gasto', style: TextStyle(fontWeight: FontWeight.bold, color: _isExpense ? Colors.redAccent : Colors.grey))),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _isExpense = false;
                        _selectedCategory = _incomeCategories.first;
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isExpense ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: !_isExpense ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : [],
                        ),
                        child: Center(child: Text('Ingreso', style: TextStyle(fontWeight: FontWeight.bold, color: !_isExpense ? const Color(0xFF2E7D32) : Colors.grey))),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Input de Cantidad (Monto) CON CONTROLADOR
            Text('Monto (Q)', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Q ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: activeColor)),
                Expanded(
                  child: TextField(
                    controller: _amountController, // Conectado al controlador
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

            // Selector de Categorías (Chips)
            Text('Categoría', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: (_isExpense ? _expenseCategories : _incomeCategories).map((category) {
                final isSelected = _selectedCategory == category;
                return ChoiceChip(
                  label: Text(category),
                  selected: isSelected,
                  selectedColor: activeColor.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? activeColor : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  backgroundColor: Colors.grey[100],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: isSelected ? activeColor.withValues(alpha: 0.5) : Colors.transparent),
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Descripción / Comercio CON CONTROLADOR
            TextField(
              controller: _noteController, // Conectado al controlador
              decoration: InputDecoration(
                hintText: 'Descripción / Comercio (ej. Starbucks)...',
                prefixIcon: const Icon(Icons.notes, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            // Botón de Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                // Si está cargando, desactivamos el botón
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Guardar Transacción',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}