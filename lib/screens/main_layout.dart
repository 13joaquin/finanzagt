// Archivo: lib/screens/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'dashboard/dashboard_screen.dart';
import 'budget_and_goals/budget_screen.dart';
import 'education/education_screen.dart';
import 'sanctuary/sanctuary_screen.dart';
import 'profile/profile_screen.dart';
import 'transactions/add_transaction_screen.dart';
import 'budget_and_goals/add_debt_screen.dart';
import 'sanctuary/add_goal_screen.dart';
import 'reports/reports_screen.dart'; // <--- IMPORTACIÓN DE INFORMES

class MainLayoutScreen extends StatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Lista de pantallas actualizada con Informes en el índice 2
  final List<Widget> _screens = [
    const MainDashboardScreen(), // 0
    const BudgetScreen(),        // 1
    const ReportsScreen(),       // 2 (NUEVA)
    const SanctuaryScreen(),     // 3
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF4A47F6);

    return Scaffold(
      key: _scaffoldKey,

      // --- PERFIL ARRIBA (ACCESO RÁPIDO) ---
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16, top: 10),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline, color: primaryColor, size: 28),
              ),
            ),
          ),
        ],
      ),

      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _buildSpeedDial(primaryColor),

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

              const SizedBox(width: 40), // Espacio para el Speed Dial central

              _buildNavItem(icon: Icons.analytics_outlined, label: 'Informes', index: 2), // <--- BOTÓN NUEVO
              _buildNavItem(icon: Icons.eco_outlined, label: 'Santuario', index: 3),
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
          Text(
              label,
              style: TextStyle(color: color, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDial(Color primaryColor) {
    return SpeedDial(
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
          child: const Icon(Icons.receipt_long_outlined, color: Colors.white),
          backgroundColor: Colors.redAccent,
          label: 'Nuevo Gasto/Ingreso',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTransactionScreen())),
        ),
        SpeedDialChild(
          child: const Icon(Icons.eco_outlined, color: Colors.white),
          backgroundColor: Colors.green,
          label: 'Nueva Meta Santuario',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddGoalScreen())),
        ),
        SpeedDialChild(
          child: const Icon(Icons.money_off_csred_outlined, color: Colors.white),
          backgroundColor: Colors.orange,
          label: 'Nueva Deuda',
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddDebtScreen())),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Color(0xFF4A47F6)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text("Menú Principal", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: Color(0xFF4A47F6)),
            title: const Text("Mi Perfil"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined, color: Color(0xFF4A47F6)),
            title: const Text("Educación Financiera"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EducationScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Configuración"),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}