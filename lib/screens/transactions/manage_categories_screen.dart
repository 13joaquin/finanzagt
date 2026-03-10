import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  bool _isExpenseTab = true;

  Future<void> _addCategory() async {
    if (_categoryController.text.isEmpty) return;
    String newCategory = _categoryController.text.trim();
    String field = _isExpenseTab ? 'expense_categories' : 'income_categories';

    await FirebaseFirestore.instance.collection('users').doc('test_user_123').update({
      field: FieldValue.arrayUnion([newCategory])
    });
    _categoryController.clear();
  }

  Future<void> _deleteCategory(String category) async {
    String field = _isExpenseTab ? 'expense_categories' : 'income_categories';
    await FirebaseFirestore.instance.collection('users').doc('test_user_123').update({
      field: FieldValue.arrayRemove([category])
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4A47F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Categorías', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueGrey[900],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tabs de Gasto / Ingreso
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isExpenseTab = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(color: _isExpenseTab ? primaryColor.withValues(alpha: 0.1) : Colors.white, border: Border(bottom: BorderSide(color: _isExpenseTab ? primaryColor : Colors.transparent, width: 2))),
                    child: Center(child: Text('Gastos', style: TextStyle(fontWeight: FontWeight.bold, color: _isExpenseTab ? primaryColor : Colors.grey))),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _isExpenseTab = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(color: !_isExpenseTab ? Colors.green.withValues(alpha: 0.1) : Colors.white, border: Border(bottom: BorderSide(color: !_isExpenseTab ? Colors.green : Colors.transparent, width: 2))),
                    child: Center(child: Text('Ingresos', style: TextStyle(fontWeight: FontWeight.bold, color: !_isExpenseTab ? Colors.green : Colors.grey))),
                  ),
                ),
              ),
            ],
          ),

          // Formulario para agregar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(hintText: 'Nueva categoría...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton(
                  onPressed: _addCategory,
                  backgroundColor: _isExpenseTab ? primaryColor : Colors.green,
                  elevation: 0,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              ],
            ),
          ),

          // Lista de Categorías desde Firebase
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance.collection('users').doc('test_user_123').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                  var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  String field = _isExpenseTab ? 'expense_categories' : 'income_categories';

                  // Si no existe la lista en Firebase, mostramos una vacía
                  List<dynamic> categories = data[field] ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(categories[index]),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteCategory(categories[index]),
                          ),
                        ),
                      );
                    },
                  );
                }
            ),
          )
        ],
      ),
    );
  }
}