import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

class AdvisorDrawer extends StatefulWidget {
  final String currentRoute;

  const AdvisorDrawer({super.key, required this.currentRoute});

  @override
  State<AdvisorDrawer> createState() => _AdvisorDrawerState();
}

class _AdvisorDrawerState extends State<AdvisorDrawer> {
  String _advisorName = 'Asesor Principal';
  String _advisorEmail = 'asesor@cajatacna.com.pe';

  @override
  void initState() {
    super.initState();
    _loadAdvisorInfo();
  }

  Future<void> _loadAdvisorInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _advisorName = prefs.getString(AppStrings.prefUserName) ?? 'Asesor Principal';
      _advisorEmail = prefs.getString(AppStrings.prefUserEmail) ?? 'asesor@cajatacna.com.pe';
    });
  }

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          // Header del Drawer
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.azulPrincipal, AppColors.azulSecundario],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 40),
            ),
            accountName: Text(
              _advisorName.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5),
            ),
            accountEmail: Text(_advisorEmail),
          ),
          
          // Elementos del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  route: AppRoutes.home,
                  icon: Icons.assignment_outlined,
                  selectedIcon: Icons.assignment,
                  title: 'Bandeja de Créditos',
                ),
                _buildMenuItem(
                  route: AppRoutes.cartera,
                  icon: Icons.directions_walk_outlined,
                  selectedIcon: Icons.directions_walk,
                  title: 'Cartera de Visitas',
                ),
                _buildMenuItem(
                  route: AppRoutes.evaluacion,
                  icon: Icons.verified_user_outlined,
                  selectedIcon: Icons.verified_user,
                  title: 'Pre-evaluar / Buró',
                ),
                _buildMenuItem(
                  route: AppRoutes.cobranza,
                  icon: Icons.monetization_on_outlined,
                  selectedIcon: Icons.monetization_on,
                  title: 'Gestión de Cobranzas',
                ),
                _buildMenuItem(
                  route: AppRoutes.reportes,
                  icon: Icons.bar_chart_outlined,
                  selectedIcon: Icons.bar_chart,
                  title: 'Metas y Reportes',
                ),
              ],
            ),
          ),

          const Divider(),
          
          // Botón Cerrar Sesión
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.rojoError),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Está seguro de que desea salir del portal de asesores?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancelar', style: TextStyle(color: AppColors.grisTexto)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _logout();
                      },
                      child: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String route,
    required IconData icon,
    required IconData selectedIcon,
    required String title,
  }) {
    final isSelected = widget.currentRoute == route;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.azulPrincipal.withOpacity(0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected ? AppColors.azulPrincipal : AppColors.grisTexto,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.azulPrincipal : AppColors.grisTexto,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        onTap: () {
          if (isSelected) {
            Navigator.pop(context); // Solo cerrar drawer
          } else {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }
}
