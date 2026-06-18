import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return Drawer(
          backgroundColor: AppColors.blancoCard,
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  color: AppColors.azulPrincipal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.naranjaBCP,
                      child: Text(
                        authProvider.currentUser?.email[0].toUpperCase() ??
                            'U',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      authProvider.currentUser?.email ?? 'Usuario',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Inicio'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance),
                title: const Text('Mis Cuentas'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
              ),
              ListTile(
                leading: const Icon(Icons.credit_card),
                title: const Text('Tarjetas'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.tarjeta);
                },
              ),
              ListTile(
                leading: const Icon(Icons.trending_up),
                title: const Text('Créditos'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.creditos);
                },
              ),
              ListTile(
                leading: const Icon(Icons.savings),
                title: const Text('Ahorros'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.ahorro);
                },
              ),
              ListTile(
                leading: const Icon(Icons.account_balance_wallet),
                title: const Text('Préstamos'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.prestamo);
                },
              ),
              ListTile(
                leading: const Icon(Icons.send),
                title: const Text('Transferencias'),
                onTap: () {
                  Navigator.pushReplacementNamed(
                      context, AppRoutes.transferencias);
                },
              ),
              ListTile(
                leading: const Icon(Icons.payment),
                title: const Text('Pagos'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.pagos);
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Perfil'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.perfil);
                },
              ),
              ListTile(
                leading: const Icon(Icons.notifications),
                title: const Text('Notificaciones'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.notifica);
                },
              ),
              ListTile(
                leading: const Icon(Icons.contact_support),
                title: const Text('Contacto'),
                onTap: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.contacto);
                },
              ),
              ListTile(
                leading: const Icon(Icons.security),
                title: const Text('Seguridad'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Seguridad - Próximamente')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Configuración - Próximamente')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.rojoError),
                title: const Text('Cerrar Sesión'),
                onTap: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
