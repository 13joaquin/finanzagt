// Archivo: lib/screens/auth/setup_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../main_layout.dart'; // Importante: Redirigir al Layout, no solo al Dashboard

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedCurrency = 'GTQ';
  bool _isLoading = false;

  final List<Map<String, String>> _currencies = [
    {'symbol': 'GTQ', 'name': 'Quetzal (Guatemala)'},
    {'symbol': 'USD', 'name': 'Dólar (EE.UU.)'},
    {'symbol': 'EUR', 'name': 'Euro (Europa)'},
    {'symbol': 'MXN', 'name': 'Peso (México)'},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-cargamos el nombre si ya existe algo en el provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().currentUser;
      if (user != null && user.displayName != "Invitado") {
        _nameController.text = user.displayName;
      }
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    if (name.isEmpty || ageText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Por favor, completa tu nombre y edad")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userProvider = context.read<UserProvider>();

      // Llamamos al método del Paso 1 que marca 'profile_completed: true'
      await userProvider.completeUserProfile(
        name: name,
        age: int.parse(ageText),
        currency: _selectedCurrency,
      );

      if (mounted) {
        // ¡EL FINALIZADOR!
        // Llevamos al usuario al Layout Principal donde están todos sus datos cargados.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final userEmail = userProvider.currentUser?.email ?? "Sin correo";

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Completar Perfil"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¡Casi listo!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "Personaliza tu experiencia financiera para empezar a usar tus cubetas.",
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Campo de Correo (Solo lectura para confirmar)
            _buildLabel("Tu cuenta vinculada:"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Text(userEmail, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            ),

            const SizedBox(height: 25),

            _buildLabel("¿Cómo te llamas?"),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: "Ej. Juan Pérez",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel("¿Qué moneda prefieres usar?"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  items: _currencies.map((c) => DropdownMenuItem(
                    value: c['symbol'],
                    child: Text(c['name']!),
                  )).toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel("Tu edad"),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: "Ej. 25",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A47F6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Comenzar mi viaje", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}