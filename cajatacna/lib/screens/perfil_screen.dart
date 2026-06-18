import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/perfil_provider.dart';
import '../widgets/app_scaffold.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  late TextEditingController _telefonoController;
  late TextEditingController _direccionController;

  @override
  void initState() {
    super.initState();
    _telefonoController = TextEditingController();
    _direccionController = TextEditingController();
    _loadPerfil();
  }

  void _loadPerfil() {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      context.read<PerfilProvider>().cargarPerfil(userId);
    }
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _direccionController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog(PerfilProvider provider) {
    final perfil = provider.perfil;
    if (perfil != null) {
      _telefonoController.text = perfil.telefono;
      _direccionController.text = perfil.direccion;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Editar mis datos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulPrincipal,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone, color: AppColors.azulPrincipal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _direccionController,
                  decoration: InputDecoration(
                    labelText: 'Dirección',
                    prefixIcon: const Icon(Icons.location_on, color: AppColors.azulPrincipal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: provider.isSaving
                        ? null
                        : () async {
                            await context.read<PerfilProvider>().actualizarPerfil(
                                  _telefonoController.text,
                                  _direccionController.text,
                                );
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Perfil actualizado con éxito.')),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.naranjaBCP,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: provider.isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Guardar',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulPrincipal)),
        content: const Text('¿Deseas cerrar sesión en este dispositivo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grisTexto)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
    
    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.register,
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final perfilProvider = context.watch<PerfilProvider>();
    
    final nombre = perfilProvider.perfil?.nombreCompleto ?? 'Usuario Caja Tacna';
    final initial = nombre.isNotEmpty ? nombre.substring(0, 1).toUpperCase() : 'U';

    return AppScaffold(
      title: 'Configuración',
      currentIndex: 3,
      body: perfilProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildUserInfo(nombre, initial, perfilProvider),
                  _buildActionGrid(),
                  _buildAjustesList(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppColors.azulPrincipal,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: const Center(
        child: Text(
          'Configuración',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfo(String name, String initial, PerfilProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE6F0FA),
            child: Text(
              initial,
              style: const TextStyle(
                color: AppColors.azulPrincipal,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.azulPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                InkWell(
                  onTap: () => _showEditProfileDialog(provider),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Edita tus datos',
                        style: TextStyle(
                          color: AppColors.naranjaBCP,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        color: AppColors.naranjaBCP,
                        size: 14,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid() {
    final gridItems = [
      (Icons.credit_card_off_outlined, 'Bloquear tarjeta'),
      (Icons.offline_pin_outlined, 'Ver Token Digital'),
      (Icons.keyboard_outlined, 'Cambia Clave Pin'),
      (Icons.lock_outline, 'Cambia Clave Digital'),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gridItems.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
        ),
        itemBuilder: (context, i) {
          final item = gridItems[i];
          return InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${item.$2} - Próximamente')),
              );
            },
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFF2F4F7)),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.$1, color: AppColors.naranjaBCP, size: 28),
                    const SizedBox(height: 10),
                    Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulPrincipal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAjustesList() {
    final items = [
      (
        Icons.security_outlined,
        'Seguridad',
        'Bloquea tu tarjeta y administra tu app'
      ),
      (
        Icons.credit_card_outlined,
        'Configuración de tarjetas',
        'Compras por internet, efectivo, extranjero'
      ),
      (
        Icons.wallet_outlined,
        'Apple Pay',
        'Administra tus tarjetas afiliadas'
      ),
      (
        Icons.tune_outlined,
        'Personaliza tu App',
        'Yapea por celular, ocultar saldos, ...'
      ),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'Ajustes',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.azulPrincipal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE6F0FA),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item.$1, color: AppColors.azulPrincipal, size: 20),
                    ),
                    title: Text(
                      item.$2,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulPrincipal,
                      ),
                    ),
                    subtitle: Text(
                      item.$3,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF667085),
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF98A2B3), size: 20),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.$2} - Disponible próximamente')),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Color(0xFFF2F4F7), indent: 72, endIndent: 24),
                ],
              )),
          // Cerrar sesión list tile
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.rojoError.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout, color: AppColors.rojoError, size: 20),
            ),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.rojoError,
              ),
            ),
            subtitle: const Text(
              'Cierra tu sesión de forma segura',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF667085),
              ),
            ),
            trailing: const Icon(Icons.chevron_right, color: Color(0xFF98A2B3), size: 20),
            onTap: _logout,
          ),
          const Divider(height: 1, color: Color(0xFFF2F4F7), indent: 72, endIndent: 24),
        ],
      ),
    );
  }
}
