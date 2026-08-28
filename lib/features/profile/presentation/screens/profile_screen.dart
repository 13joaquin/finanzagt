// Archivo: lib/screens/profile/profile_screen.dart


import 'package:finanzagt/features/profile/presentation/screens/profile_anon_screen.dart';
import 'package:finanzagt/features/profile/presentation/screens/profile_registered_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/user_provider.dart';
import '../../../goals/presentation/savings_goals_screen.dart';
import '../../../transactions/presentation/screens/manage_categories_screen.dart';
import '../components/feedback_bottom_sheet.dart';



class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final isAnonymous = user?.isAnonymous ?? true;
    const Color primaryColor = Color(0xFF4A47F6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFF8F9FE),
        elevation: 0,
        foregroundColor: Colors.black,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // --- 1. SECCIÓN DINÁMICA DE USUARIO ---
            if (isAnonymous)
              const ProfileAnonSection()
            else
              const ProfileRegisteredSection(),

            const SizedBox(height: 30),

            // --- 2. HERRAMIENTAS DE LA APLICACIÓN (Manteniendo tus flujos originales) ---
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 10),
                child: Text(
                  "Herramientas y Configuración",
                  style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildMenuTile(
                    context: context,
                    icon: Icons.category_outlined,
                    color: primaryColor,
                    title: "Gestionar Categorías",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ManageCategoriesScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 55),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.savings_outlined,
                    color: Colors.green,
                    title: "Metas de Ahorro",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavingsGoalsScreen()),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 55),
                  _buildMenuTile(
                    context: context,
                    icon: Icons.mail_outline,
                    color: Colors.purple,
                    title: "Soporte y Feedback",
                    onTap: () => _showFeedbackBottomSheet(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _showFeedbackBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FeedbackBottomSheet(),
    );
  }
  Widget _buildMenuTile({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
    );
  }
}
