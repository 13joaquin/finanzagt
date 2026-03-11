import 'package:finanzagt/screens/sanctuary/sanctuary_screen.dart';
import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/add_transaction_screen.dart';
import 'budget_and_goals/budget_screen.dart';
import 'education/education_screen.dart';// NUEVA IMPORTACIÓN

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() =>  _MainLayotSreenState();
}

class _MainLayotSreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  // Lista de pantallas para navegar
  final List<Widget> _screens = [
    const MainDashboardScreen(), // 0: Inicio (Dashboard)
    const BudgetScreen(),        // 1: Presupuesto (¡CONECTADO AL MENÚ!)
    const EducationScreen(), // 2: Educación
    const SanctuaryScreen(), // 3: Santuario
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: _screens[_currentIndex], // Muestra la pantalla según la pestaña

      // Botón flotante central
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTransactionScreen(),
          );
        },
        backgroundColor: primaryColor,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),

      // Acopla el botón flotante al centro de la barra inferior
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // Barra de navegación inferior
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: Colors.white,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.grid_view_rounded, label: 'Inicio', index: 0),
              _buildNavItem(icon: Icons.pie_chart_outline, label: 'Presupuesto', index: 1),
              const SizedBox(width: 40),
              _buildNavItem(icon: Icons.menu_book_rounded, label: 'Educación', index: 2),
              _buildNavItem(icon: Icons.eco_outlined, label: 'Santuario', index: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem ({required IconData icon, required String label, required int index}){
    bool isSelected = _currentIndex == index;
    final Color color = isSelected ? Theme.of(context).colorScheme.primary : Colors.grey;

    return InkWell(
      onTap: (){
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          )
        ],
      ),
    );
  }
}