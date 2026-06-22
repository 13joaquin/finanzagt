// Archivo: lib/screens/transactions/manage_categories_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../auth/auth_screen.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  final TextEditingController _categoryController = TextEditingController();
  bool _isExpenseTab = true;

  Future<void> _addCategory(String uid) async {
    if (_categoryController.text.isEmpty) return;
    String newCategory = _categoryController.text.trim();
    String field = _isExpenseTab ? 'expense_categories' : 'income_categories';

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      field: FieldValue.arrayUnion([newCategory])
    });
    _categoryController.clear();
  }

  Future<void> _deleteCategory(String uid, String category) async {
    String field = _isExpenseTab ? 'expense_categories' : 'income_categories';
    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      field: FieldValue.arrayRemove([category])
    });
  }

  // 🆕 Diálogo para usuario que no es Pro
  void _showProRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.lock_outline, color: Color(0xFF4A47F6)),
            SizedBox(width: 10),
            Text('Función Pro', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: const Text(
          'Crear y eliminar categorías personalizadas es una función exclusiva.\n\n'
              'Sube de nivel creando una cuenta para desbloquear el control total de tus finanzas.',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Más tarde', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AuthScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A47F6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Desbloquear ahora', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el proveedor y el estado Pro
    final userProvider = Provider.of<UserProvider>(context);
    final uid = userProvider.currentUser?.uid;
    final bool isPro = userProvider.isPro; // <-- ✨ LECTURA DEL ESTADO PRO

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

          // ✨ BLOQUEO VISUAL DEL INPUT
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: isPro ? null : _showProRequiredDialog, // Intercepta toques si está bloqueado
              child: AbsorbPointer(
                absorbing: !isPro, // Evita que el teclado se abra si no es Pro
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _categoryController,
                        enabled: isPro, // Deshabilita el input visualmente
                        decoration: InputDecoration(
                          hintText: isPro ? 'Nueva categoría...' : 'Función bloqueada...',
                          filled: true,
                          fillColor: isPro ? Colors.white : Colors.grey.shade200,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          prefixIcon: isPro ? null : const Icon(Icons.lock, color: Colors.grey, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: isPro ? () => _addCategory(uid) : _showProRequiredDialog,
                      icon: Icon(isPro ? Icons.add : Icons.lock_outline),
                      style: IconButton.styleFrom(
                        backgroundColor: isPro ? primaryColor : Colors.grey.shade400,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // LISTA DINÁMICA DE CATEGORÍAS[cite: 5]
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
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
                          title: Text(categories[index], style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: isPro ? Colors.black : Colors.grey.shade700 // Texto sutilmente apagado si no es pro
                          )),
                          // ✨ BLOQUEO VISUAL DEL BOTÓN ELIMINAR
                          trailing: IconButton(
                            icon: Icon(
                              isPro ? Icons.delete_outline : Icons.lock_outline,
                              color: isPro ? Colors.redAccent : Colors.grey.shade400,
                              size: isPro ? 24 : 20,
                            ),
                            onPressed: isPro ? () => _deleteCategory(uid, categories[index]) : _showProRequiredDialog,
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