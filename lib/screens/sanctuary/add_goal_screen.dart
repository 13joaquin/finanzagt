import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/GoalProvider.dart'; // Verifica el nombre exacto de tu archivo

class AddGoalScreen extends StatefulWidget {
  const AddGoalScreen({super.key});

  @override
  State<AddGoalScreen> createState() => _AddGoalScreenState();
}

class _AddGoalScreenState extends State<AddGoalScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Nueva Meta de Ahorro")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "¿Para qué estás ahorrando?", hintText: "Ej. Fondo de Emergencia"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Monto Objetivo", prefixText: "Q "),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () {
                  // Lógica para guardar usando el GoalProvider
                  final name = _nameController.text;
                  final target = double.tryParse(_amountController.text) ?? 0.0;

                  if(name.isNotEmpty && target > 0) {
                    // Aquí llamarías a: context.read<GoalProvider>().addGoal(...)
                    Navigator.pop(context);
                  }
                },
                child: const Text("Crear Meta", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}