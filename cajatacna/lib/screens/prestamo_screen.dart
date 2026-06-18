import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../models/prestamo_models.dart';
import '../models/solicitud_prestamo_model.dart';
import '../repositories/prestamo_repository.dart';
import '../providers/solicitud_provider.dart';
import '../core/network/supabase_client.dart';
import '../widgets/app_scaffold.dart';

class PrestamoScreen extends StatefulWidget {
  const PrestamoScreen({super.key});

  @override
  State<PrestamoScreen> createState() => _PrestamoScreenState();
}

class _PrestamoScreenState extends State<PrestamoScreen> {
  List<Prestamo> _prestamos = [];
  bool _isLoading = true;
  String? _error;
  int _activeTab = 0; // 0 = Activos, 1 = Solicitudes

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = PrestamoRepository(SupabaseClient());
      final prestamos = await repo.getPrestamos();
      if (mounted) {
        setState(() {
          _prestamos = prestamos;
        });
      }
      
      if (!mounted) return;
      // Cargar solicitudes de préstamo
      await context.read<SolicitudProvider>().cargarSolicitudes();
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Préstamos Caja Tacna',
      currentIndex: 0,
      showAppBar: true,
      body: Column(
        children: [
          // Selector de pestañas personalizado
          Container(
            color: AppColors.azulPrincipal,
            child: Row(
              children: [
                _buildTabItem(0, 'Préstamos Activos'),
                _buildTabItem(1, 'Mis Solicitudes'),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.naranjaBCP))
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_error!, style: const TextStyle(color: AppColors.rojoError)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.azulPrincipal,
                              ),
                              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : _activeTab == 0
                        ? _buildPrestamosActivos()
                        : _buildSolicitudesList(),
          ),

          // Botón inferior para solicitar préstamo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, AppRoutes.solicitarPrestamo);
                  if (result == true) {
                    _loadData();
                  }
                },
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Solicitar Préstamo Al Instante',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.naranjaBCP,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
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
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? AppColors.naranjaBCP : Colors.transparent,
                width: 3.0,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrestamosActivos() {
    if (_prestamos.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance, size: 64, color: Color(0xFFD0D5DD)),
              SizedBox(height: 16),
              Text(
                'No tienes préstamos activos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.grisTexto,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Solicita uno presionando el botón de abajo.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF667085), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.naranjaBCP,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _prestamos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemBuilder: (context, index) => _PrestamoCard(prestamo: _prestamos[index]),
      ),
    );
  }

  Widget _buildSolicitudesList() {
    return Consumer<SolicitudProvider>(
      builder: (context, provider, _) {
        final list = provider.solicitudes;
        if (provider.error != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.rojoError),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulPrincipal,
                    ),
                    child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        if (list.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Color(0xFFD0D5DD)),
                  SizedBox(height: 16),
                  Text(
                    'Aún no has solicitado préstamos',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.grisTexto,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Completa tu primera solicitud rápida en minutos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          color: AppColors.naranjaBCP,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _SolicitudCard(solicitud: list[index]),
          ),
        );
      },
    );
  }
}

class _PrestamoCard extends StatelessWidget {
  final Prestamo prestamo;
  const _PrestamoCard({required this.prestamo});

  @override
  Widget build(BuildContext context) {
    final progreso = prestamo.cuotasTotal > 0
        ? prestamo.cuotaNumero / prestamo.cuotasTotal
        : 0.0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.azulPrincipal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.account_balance_wallet_outlined,
                      color: AppColors.azulPrincipal, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prestamo.tipo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: Color(0xFF1A2340),
                        ),
                      ),
                      Text(
                        prestamo.numeroEnmascarado,
                        style: const TextStyle(color: AppColors.grisTexto, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.verdeExito.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Activo',
                    style: TextStyle(
                      color: AppColors.verdeExito,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Capital total',
                    value: 'S/ ${prestamo.capitalTotal.toStringAsFixed(2)}',
                    valueColor: AppColors.azulPrincipal,
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    label: 'Saldo pendiente',
                    value: 'S/ ${prestamo.capitalPendiente.toStringAsFixed(2)}',
                    valueColor: AppColors.naranjaBCP,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _InfoTile(
                    label: 'Cuota mensual',
                    value: 'S/ ${prestamo.totalCuota.toStringAsFixed(2)}',
                    valueColor: const Color(0xFF1A2340),
                  ),
                ),
                Expanded(
                  child: _InfoTile(
                    label: 'Próximo pago',
                    value: prestamo.fechaLimite,
                    valueColor: const Color(0xFF1A2340),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cuota ${prestamo.cuotaNumero} de ${prestamo.cuotasTotal}',
                  style: const TextStyle(fontSize: 13, color: AppColors.grisTexto),
                ),
                Text(
                  '${(progreso * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.azulPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progreso.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: const Color(0xFFEDEFF3),
                valueColor: const AlwaysStoppedAnimation(AppColors.azulPrincipal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolicitudCard extends StatelessWidget {
  final SolicitudPrestamo solicitud;
  const _SolicitudCard({required this.solicitud});

  @override
  Widget build(BuildContext context) {
    Color estadoColor = AppColors.naranjaAviso;
    String estadoTexto = 'Pendiente';
    IconData estadoIcon = Icons.hourglass_empty;

    if (solicitud.estado == 'aprobado') {
      estadoColor = AppColors.verdeExito;
      estadoTexto = 'Aprobado';
      estadoIcon = Icons.check_circle_outline;
    } else if (solicitud.estado == 'rechazado') {
      estadoColor = AppColors.rojoError;
      estadoTexto = 'Rechazado';
      estadoIcon = Icons.cancel_outlined;
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Solicitud de Préstamo',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppColors.azulPrincipal,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: estadoColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(estadoIcon, color: estadoColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        estadoTexto,
                        style: TextStyle(
                          color: estadoColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: Color(0xFFF2F4F7)),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto solicitado', style: TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        'S/ ${solicitud.montoSolicitado.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF1A2340),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Plazo solicitado', style: TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        '${solicitud.cuotas} meses',
                        style: const TextStyle(
                          color: Color(0xFF1A2340),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Motivo', style: TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        solicitud.motivo,
                        style: const TextStyle(
                          color: Color(0xFF344054),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fecha de solicitud', style: TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        '${solicitud.createdAt.day.toString().padLeft(2, '0')}/${solicitud.createdAt.month.toString().padLeft(2, '0')}/${solicitud.createdAt.year}',
                        style: const TextStyle(
                          color: Color(0xFF344054),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.grisTexto, fontSize: 12)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ],
    );
  }
}
