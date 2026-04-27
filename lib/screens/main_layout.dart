import 'package:finanzagt/screens/sanctuary/sanctuary_screen.dart';
import 'package:flutter/material.dart';
import 'dashboard/dashboard_screen.dart';
import 'transactions/add_transaction_screen.dart';
import 'budget_and_goals/budget_screen.dart';
import 'education/education_screen.dart';
// IMPORTAMOS LA PANTALLA DE PERFIL
import 'profile/profile_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;

  // Lista de pantallas para navegar (Agregamos Perfil al final)
  final List<Widget> _screens = [
    const MainDashboardScreen(), // 0: Inicio
    const BudgetScreen(), // 1: Presupuesto
    const EducationScreen(), // 2: Educación
    const SanctuaryScreen(), // 3: Santuario
    const ProfileScreen(), // 4: Perfil
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme
        .of(context)
        .colorScheme
        .primary;

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
        child: Container( // Cambiamos SizedBox por Container para mejor control
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 0),
          // Quitamos padding lateral
          child: Row(
            children: [
              // LADO IZQUIERDO (2 Iconos)
              Expanded(child: _buildNavItem(
                  icon: Icons.grid_view_rounded, label: 'Inicio', index: 0)),
              Expanded(child: _buildNavItem(icon: Icons.pie_chart_outline,
                  label: 'Presupuesto',
                  index: 1)),

              // ESPACIO PARA EL BOTÓN CENTRAL (El "Notch")
              // Aumentamos a 60 para que el botón (+) respire y no choque con los textos
              const SizedBox(width: 60),

              // LADO DERECHO (3 Iconos)
              Expanded(child: _buildNavItem(
                  icon: Icons.menu_book_rounded, label: 'Educación', index: 2)),
              Expanded(child: _buildNavItem(
                  icon: Icons.eco_outlined, label: 'Santuario', index: 3)),
              Expanded(child: _buildNavItem(
                  icon: Icons.person_outline, label: 'Perfil', index: 4)),
            ],
          ),
        ),
      ),
    );
  }

  // Ajuste ligero al NavItem para que el texto no se vea apretado
  Widget _buildNavItem(
      {required IconData icon, required String label, required int index}) {
    bool isSelected = _currentIndex == index;
    final Color color = isSelected ? Theme
        .of(context)
        .colorScheme
        .primary : Colors.grey;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 22),
          // Reducimos un pelín el icono si es necesario
          FittedBox( // Este widget hace que el texto se ajuste si no cabe
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                // Reducimos a 11 para que "Presupuesto" y "Educación" quepan bien
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          )
        ],
      ),
    );
  }
}