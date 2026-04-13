import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../providers/user_provider.dart';
// IMPORTANTE: Cambia esta ruta por la de tu pantalla base que contiene el menú inferior
import '../dashboard/dashboard_screen.dart';

class SetupProfileScreen extends StatefulWidget {
  const SetupProfileScreen({super.key});

  @override
  State<SetupProfileScreen> createState() => _SetupProfileScreenState();
}

class _SetupProfileScreenState extends State<SetupProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String _selectedCurrency = 'Q'; // Por defecto Quetzales
  bool _isLoading = false;

  final List<Map<String, String>> _currencies = [
    {'symbol': 'Q', 'name': 'Quetzal (GTQ)'},
    {'symbol': '\$', 'name': 'Dólar (USD)'},
    {'symbol': '€', 'name': 'Euro (EUR)'},
    {'symbol': '\$', 'name': 'Peso (MXN/COP/ARS)'},
  ];

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final ageText = _ageController.text.trim();

    // Validaciones...
    if (name.isEmpty || ageText.isEmpty) return;
    final age = int.tryParse(ageText);
    if (age == null) return;

    setState(() => _isLoading = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Llamamos al nuevo método del Provider que arreglamos arriba
      await userProvider.completeUserProfile(
        name: name,
        age: age,
        currency: _selectedCurrency,
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
        );
      }
    } catch (e) {
      // Manejo de error...
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF4A47F6);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Ícono decorativo
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.psychology_alt_rounded, size: 40, color: primaryColor),
              ),
              const SizedBox(height: 25),

              // Textos de bienvenida
              Text(
                'Personaliza tu\nexperiencia',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueGrey[900], height: 1.2),
              ),
              const SizedBox(height: 10),
              Text(
                'Cuéntanos un poco sobre ti para adaptar Finavid a tus necesidades.',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),

              // Formulario: Nombre
              _buildInputLabel('¿Cómo te llamamos?'),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: 'Ej. Carlos, Ana...',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 25),

              // Formulario: Edad
              _buildInputLabel('¿Cuántos años tienes?'),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Ej. 28',
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  prefixIcon: Icon(Icons.cake_outlined, color: Colors.grey[400]),
                ),
              ),
              const SizedBox(height: 25),

              // Formulario: Moneda
              _buildInputLabel('Tu moneda principal'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCurrency,
                    isExpanded: true,
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
                    items: _currencies.map((curr) {
                      return DropdownMenuItem(
                        value: curr['symbol'],
                        child: Text('${curr['symbol']} - ${curr['name']}'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCurrency = value);
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // Botón de Guardar
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                      'Comenzar mi viaje',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
      ),
    );
  }
}