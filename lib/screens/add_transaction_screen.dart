import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  // Estado para controlar si es Gasto (true) o Ingreso (false)
  bool _isExpense = true;
  String _selectedCategory = 'Comida'; // Categoría por defecto

  // Lista temporal de categorías (luego vendrán de Firebase)
  final List<String> _expenseCategories = ['Comida', 'Transporte', 'Servicios', 'Ocio', 'Salud'];
  final List<String> _incomeCategories = ['Salario', 'Negocio', 'Inversión', 'Regalo', 'Otros'];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;
    final Color activeColor = _isExpense ? Colors.redAccent : const Color(0xFF2E7D32); // Rojo para gasto, Verde para ingreso

    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // Ocupa el 85% de la pantalla
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
            // 1. Barra indicadora de arrastre y Título
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nueva Transacción',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey[900]),
            ),
            const SizedBox(height: 20),

            // 2. Selector (Toggle) Gasto / Ingreso
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
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
                        child: Center(
                          child: Text('Gasto', style: TextStyle(fontWeight: FontWeight.bold, color: _isExpense ? Colors.redAccent : Colors.grey)),
                        ),
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
                        child: Center(
                          child: Text('Ingreso', style: TextStyle(fontWeight: FontWeight.bold, color: !_isExpense ? const Color(0xFF2E7D32) : Colors.grey)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // 3. Input de Cantidad (Monto)
            Text('Monto', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Q ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: activeColor)),
                Expanded(
                  child: TextField(
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

            // 4. Selector de Categorías (Chips)
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

            // 5. Nota opcional
            TextField(
              decoration: InputDecoration(
                hintText: 'Añadir una nota (opcional)...',
                prefixIcon: const Icon(Icons.notes, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(), // Empuja el botón hacia abajo

            // 6. Botón de Guardar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  // AQUI IRÁ LA LÓGICA DE FIREBASE MÁS ADELANTE
                  Navigator.pop(context); // Cierra el modal por ahora
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: activeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text(
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