// Archivo: lib/screens/auth/setup_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '';
import '../../../../app/layout/main_layout.dart';
import '../providers/user_provider.dart';


class SetupProfileScreen extends ConsumerStatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  ConsumerState<SetupProfileScreen> createState() =>
      _SetupProfileScreenState();
}

class _SetupProfileScreenState extends ConsumerState<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedCurrency = 'GTQ';
  bool _isLoading = false;

  final List<Map<String, String>> _currencies = [
    {'symbol': 'GTQ', 'name': 'Quetzal (Guatemala)'},
    {'symbol': 'USD', 'name': 'Dolar (EE.UU.)'},
    {'symbol': 'EUR', 'name': 'Euro (Europa)'},
    {'symbol': 'MXN', 'name': 'Peso (México)'},
  ];

  @override
  void initState() {
    super.initState();
    // Pre-cargamos el nombre si ya existe algo en el provider (ej. si Firebase traía algo)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(userProvider);
      if (user != null &&
          user.displayName.isNotEmpty &&
          user.displayName != "Invitado") {
        _nameController.text = user.displayName;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  // --- CONEXIÓN CON EL USERPROVIDER ---
  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final ageString = _ageController.text.trim();

    // 1. Validaciones de campos
    if (name.isEmpty) {
      _showSnackBar("Por favor, ingresa tu nombre");
      return;
    }

    if (ageString.isEmpty) {
      _showSnackBar("Por favor, ingresa tu edad");
      return;
    }

    final int? age = int.tryParse(ageString);
    if (age == null || age <= 0) {
      _showSnackBar("Por favor, ingresa una edad válida");
      return;
    }

    // 2. Ejecución del guardado a través del Provider
    setState(() => _isLoading = true);

    try {
      await ref.read(userProvider.notifier).completeUserProfile(
        name: name,
        age: age,
        currency: _selectedCurrency,
      );

      // 3. CAMBIO CRÍTICO: Navegación Absoluta y Segura (Sincronizada con Splash Boot)
      if (mounted) {
        // Al no existir el AuthGate, destruimos todo el historial previo (WelcomeScreen, AuthScreen)
        // para garantizar que el Layout Principal sea el origen definitivo del flujo.
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainLayoutScreen()),
              (route) => false, // Rompe todo el historial de navegación de atrás
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Error al guardar el perfil: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Configura tu Perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¡Te damos la bienvenida a FinanzaGT!\nQueremos conocerte un poco mejor para adaptar tu experiencia.",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 30),

            _buildLabel("Tu nombre"),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                hintText: "Ej. Carlos López",
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Color(0xFF4A47F6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),

            const SizedBox(height: 20),

            _buildLabel("Moneda principal"),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedCurrency,
                  isExpanded: true,
                  items: _currencies.map((currency) {
                    return DropdownMenuItem<String>(
                      value: currency['symbol'],
                      child: Text(
                        "${currency['name']} (${currency['symbol']})",
                      ),
                    );
                  }).toList(),
                  onChanged: (val) =>
                      setState(() => _selectedCurrency = val!),
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
                prefixIcon: const Icon(
                  Icons.cake_outlined,
                  color: Color(0xFF4A47F6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  "Comenzar mi viaje",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      ),
    );
  }
}