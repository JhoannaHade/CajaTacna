import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final int currentIndex;
  final bool showBottomNav;
  final bool showAppBar;
  final List<Widget>? actions;

  const AppScaffold({
    required this.body,
    required this.title,
    required this.currentIndex,
    this.showBottomNav = true,
    this.showAppBar = false,
    this.actions,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              backgroundColor: AppColors.azulPrincipal,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              actions: actions,
            )
          : null,
      body: SafeArea(child: body),
      bottomNavigationBar: showBottomNav
          ? Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFEAECF0), width: 1),
                ),
              ),
              child: BottomNavigationBar(
                backgroundColor: Colors.white,
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                currentIndex: currentIndex,
                selectedItemColor: AppColors.azulPrincipal,
                unselectedItemColor: const Color(0xFF98A2B3),
                selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                onTap: (index) {
                  _navigateToIndex(context, index);
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: 'Inicio',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.swap_horiz),
                    activeIcon: Icon(Icons.swap_horiz),
                    label: 'Operaciones',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_outlined),
                    activeIcon: Icon(Icons.shopping_cart),
                    label: 'Para ti',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: 'Configuración',
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _navigateToIndex(BuildContext context, int index) {
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1:
        Navigator.pushReplacementNamed(context, AppRoutes.opera);
        break;
      case 2:
        Navigator.pushReplacementNamed(context, AppRoutes.contacto);
        break;
      case 3:
        Navigator.pushReplacementNamed(context, AppRoutes.perfil);
        break;
    }
  }
}
