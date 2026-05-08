// Archivo: lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; // Asegúrate de agregarlo al pubspec.yaml
import 'dashboard/dashboard_screen.dart';
import 'budget_and_goals/budget_screen.dart';
import 'education/education_screen.dart';
import 'sanctuary/sanctuary_screen.dart';
import 'profile/profile_screen.dart';
import 'transactions/add_transaction_screen.dart';
import 'budget_and_goals/add_debt_screen.dart';
import 'sanctuary/add_goal_screen.dart';

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // PASO 6: Lista de pantallas principales (Navegación directa)
  final List<Widget> _screens = [
    const MainDashboardScreen(), // 0
    const BudgetScreen(),        // 1
    const SanctuaryScreen(),     // 2
  ];

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF4A47F6); // Tu color principal

    return Scaffold(
      key: _scaffoldKey,
      // EL CUERPO cambia según la barra inferior
      body: _screens[_currentIndex],

      // EL DRAWER (Menú Lateral) para Educación y Perfil
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: primaryColor),
              accountName: const Text("Mi Progreso Financiero", style: TextStyle(fontWeight: FontWeight.bold)),
              accountEmail: const Text("Configuración y Aprendizaje"),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Color(0xFF4A47F6), size: 40),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.school_outlined),
              title: const Text("Educación Financiera"),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
                Navigator.push(context, MaterialPageRoute(builder: (context) => const EducationScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text("Mi Perfil / Ajustes"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
            const Spacer(),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("FinanzaGT v1.1", style: TextStyle(color: Colors.grey, fontSize: 12)),
            )
          ],
        ),
      ),

      // PASO 7: SPEED DIAL (Botón flotante estilo X)
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        overlayColor: Colors.black,
        overlayOpacity: 0.5,
        spacing: 12,
        spaceBetweenChildren: 12,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.remove_circle_outline),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            label: 'Nuevo Gasto',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen())),
          ),
          SpeedDialChild(
            child: const Icon(Icons.add_circle_outline),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            label: 'Nuevo Ingreso',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen())),
          ),
          SpeedDialChild(
            child: const Icon(Icons.eco_outlined),
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            label: 'Meta Santuario',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen())),
          ),
          SpeedDialChild(
            child: const Icon(Icons.money_off_csred_outlined),
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            label: 'Registrar Deuda',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDebtScreen())),
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // BARRA INFERIOR (Estilo UX original)
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(icon: Icons.dashboard_outlined, label: 'Inicio', index: 0),
              _buildNavItem(icon: Icons.account_balance_wallet_outlined, label: 'Presupuesto', index: 1),
              const SizedBox(width: 40), // Espacio para el Speed Dial si estuviera al centro
              _buildNavItem(icon: Icons.eco_outlined, label: 'Santuario', index: 2),
              // Botón para abrir el Drawer (Educación/Perfil)
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.grey),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required String label, required int index}) {
    bool isSelected = _currentIndex == index;
    final Color color = isSelected ? const Color(0xFF4A47F6) : Colors.grey;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}