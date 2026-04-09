import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart'; // IMPORTANTE: Para acceder al usuario
import '../../providers/user_provider.dart'; // IMPORTANTE: Tu provider de usuario

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  bool _isExpenseTab = true;

  // FUNCIÓN PARA AGREGAR: Ahora pide el UID
  Future<void> _addCategory(String uid) async {
    if (_categoryController.text.isEmpty) return;
    String newCategory = _categoryController.text.trim();
    String field = _isExpenseTab ? 'expense_categories' : 'income_categories';

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      field: FieldValue.arrayUnion([newCategory])
    });
    _categoryController.clear();
  }

  // FUNCIÓN PARA ELIMINAR: Ahora pide el UID
  Future<void> _deleteCategory(String uid, String category) async {
    String field = _isExpenseTab ? 'expense_categories' : 'income_categories';
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      field: FieldValue.arrayRemove([category])
    });
  }

  @override
  Widget build(BuildContext context) {
    // 1. OBTENEMOS EL UID DINÁMICO
    final userProvider = Provider.of<UserProvider>(context);
    final uid = userProvider.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Color primaryColor = const Color(0xFF4A47F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Gestionar Categorías', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Selector de Tipo (Gasto / Ingreso)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(child: _typeTab("Gastos", true)),
                const SizedBox(width: 10),
                Expanded(child: _typeTab("Ingresos", false)),
              ],
            ),
          ),

          // Campo para agregar nueva categoría
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _categoryController,
                    decoration: InputDecoration(
                      hintText: 'Nueva categoría...',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: () => _addCategory(uid), // <-- Enviamos el UID real
                  icon: const Icon(Icons.add),
                  style: IconButton.styleFrom(backgroundColor: primaryColor),
                )
              ],
            ),
          ),

          const SizedBox(height: 20),

          // LISTA DINÁMICA DE CATEGORÍAS
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              // 2. USAMOS EL UID REAL EN EL STREAM
                stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(child: Text("Crea tu primera categoría"));
                  }

                  var data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
                  String field = _isExpenseTab ? 'expense_categories' : 'income_categories';

                  List<dynamic> categories = data[field] ?? [];

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: ListTile(
                          title: Text(categories[index], style: const TextStyle(fontWeight: FontWeight.w500)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _deleteCategory(uid, categories[index]), // <-- Enviamos el UID real
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

  Widget _typeTab(String label, bool isExpense) {
    bool active = _isExpenseTab == isExpense;
    return GestureDetector(
      onTap: () => setState(() => _isExpenseTab = isExpense),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF4A47F6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: active ? null : Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(color: active ? Colors.white : Colors.grey, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}