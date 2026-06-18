import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/solicitud_provider.dart';
import '../models/solicitud_prestamo_model.dart';
import '../widgets/advisor_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _advisorName = 'Asesor Principal';
  int _activeTab = 0; // 0 = Pendientes, 1 = Historial (Aprobados/Rechazados)

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _advisorName = prefs.getString(AppStrings.prefUserName) ?? 'Asesor Principal';
      });
      // Cargar todas las solicitudes del sistema
      context.read<SolicitudProvider>().cargarSolicitudes();
    }
  }

  Future<void> _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudProvider>();
    final todas = provider.solicitudes;

    // Filtrar solicitudes
    final pendientes = todas.where((s) => s.estado == 'pendiente').toList();
    final historial = todas.where((s) => s.estado != 'pendiente').toList();

    return Scaffold(
      backgroundColor: AppColors.fondoGrisClaro,
      drawer: const AdvisorDrawer(currentRoute: AppRoutes.home),
      appBar: AppBar(
        title: const Text(
          'Portal Asesores Caja Tacna',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.azulPrincipal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar Sesión',
            onPressed: () {
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
        ],
      ),
      body: provider.isLoading && todas.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.naranjaBCP))
          : provider.error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppColors.rojoError),
                        const SizedBox(height: 16),
                        Text(
                          provider.error!,
                          style: const TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => provider.cargarSolicitudes(),
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulPrincipal),
                          child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => provider.cargarSolicitudes(),
                  color: AppColors.naranjaBCP,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header de Bienvenida
                        _buildWelcomeHeader(),

                        // Panel de Estadísticas / Métricas
                        _buildStatsPanel(provider),

                        const SizedBox(height: 8),

                        // Selector de Tab (Pendientes vs Historial)
                        _buildTabSelector(),

                        // Listado
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: _activeTab == 0
                              ? _buildSolicitudesList(pendientes, 'No hay solicitudes pendientes.')
                              : _buildSolicitudesList(historial, 'No hay solicitudes en el historial.'),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Container(
      color: AppColors.azulPrincipal,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sesión activa como:',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            _advisorName.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(SolicitudProvider provider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Métricas de Evaluación',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.azulPrincipal,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Pendientes Card
              Expanded(
                child: _buildMetricCard(
                  title: 'Pendientes',
                  value: '${provider.solicitudesPendientesCount}',
                  icon: Icons.pending_actions,
                  color: AppColors.naranjaBCP,
                ),
              ),
              const SizedBox(width: 12),
              // Aprobados Card
              Expanded(
                child: _buildMetricCard(
                  title: 'Aprobados',
                  value: '${provider.solicitudesAprobadasCount}',
                  icon: Icons.task_alt,
                  color: AppColors.verdeExito,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Total desembolsado
          _buildTotalDisbursedCard(provider.totalMontoAprobado),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.12), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppColors.grisTexto, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalDisbursedCard(double total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6F0FA), Color(0xFFCBE0F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB9D5F3), width: 1),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.azulPrincipal,
            child: Icon(Icons.monetization_on, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Desembolsado (Clientes Caja Tacna)',
                  style: TextStyle(color: AppColors.azulPrincipal, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'S/ ${total.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.azulOscuro, fontSize: 20, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      color: Colors.white,
      child: Row(
        children: [
          _buildTabItem(0, 'Pendientes de Aprobación'),
          _buildTabItem(1, 'Historial de Decisiones'),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    final isSelected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _activeTab = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.azulPrincipal : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? AppColors.azulPrincipal : const Color(0xFF667085),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitudesList(List<SolicitudPrestamo> list, String emptyMessage) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Column(
            children: [
              const Icon(Icons.inbox, size: 48, color: Color(0xFFD0D5DD)),
              const SizedBox(height: 12),
              Text(
                emptyMessage,
                style: const TextStyle(color: AppColors.grisTexto, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final solicitud = list[index];
        return _SolicitudItemCard(
          solicitud: solicitud,
          onTap: () async {
            final result = await Navigator.pushNamed(
              context,
              AppRoutes.detalleSolicitud,
              arguments: solicitud,
            );
            if (result == true) {
              context.read<SolicitudProvider>().cargarSolicitudes();
            }
          },
        );
      },
    );
  }
}

class _SolicitudItemCard extends StatelessWidget {
  final SolicitudPrestamo solicitud;
  final VoidCallback onTap;

  const _SolicitudItemCard({
    required this.solicitud,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color estadoColor = AppColors.naranjaAviso;
    String estadoTexto = 'Pendiente';

    if (solicitud.estado == 'aprobado') {
      estadoColor = AppColors.verdeExito;
      estadoTexto = 'Aprobado';
    } else if (solicitud.estado == 'rechazado') {
      estadoColor = AppColors.rojoError;
      estadoTexto = 'Rechazado';
    }

    final String clientName = solicitud.clienteNombre ?? 'Cliente Caja Tacna';
    final String clientDni = solicitud.clienteDni != null ? 'DNI: ${solicitud.clienteDni}' : 'DNI: N/A';

    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icono de cliente
                  CircleAvatar(
                    backgroundColor: AppColors.azulPrincipal.withOpacity(0.06),
                    radius: 20,
                    child: const Icon(Icons.person_outline, color: AppColors.azulPrincipal, size: 20),
                  ),
                  const SizedBox(width: 12),
                  // Nombre y DNI
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Color(0xFF1A2340),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          clientDni,
                          style: const TextStyle(color: AppColors.grisTexto, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Estado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      estadoTexto,
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24, color: Color(0xFFF2F4F7)),
              // Detalles del préstamo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto solicitado', style: TextStyle(color: AppColors.grisTexto, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        'S/ ${solicitud.montoSolicitado.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.azulPrincipal,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plazo', style: TextStyle(color: AppColors.grisTexto, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        '${solicitud.cuotas} meses',
                        style: const TextStyle(
                          color: Color(0xFF1A2340),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF98A2B3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
