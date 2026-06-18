import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/solicitud_provider.dart';
import '../widgets/advisor_drawer.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      context.read<SolicitudProvider>().cargarSolicitudes();
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SolicitudProvider>();
    
    // Metas fijas del mes
    const double metaColocacion = 100000.0;
    const int metaExpedientes = 8;

    // Resultados reales calculados de la base de datos
    final double avanceColocacion = provider.totalMontoAprobado;
    final int avanceExpedientes = provider.solicitudesAprobadasCount;
    final double comisionAcumulada = avanceColocacion * 0.01; // 1% de comisión real

    final double porcentajeColocacion = (avanceColocacion / metaColocacion).clamp(0.0, 1.0);
    final double porcentajeExpedientes = (avanceExpedientes / metaExpedientes).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: AppColors.fondoGrisClaro,
      drawer: const AdvisorDrawer(currentRoute: AppRoutes.reportes),
      appBar: AppBar(
        title: const Text(
          'Productividad y Metas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.azulPrincipal,
        elevation: 0,
      ),
      body: provider.isLoading && provider.solicitudes.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.naranjaBCP))
          : RefreshIndicator(
              onRefresh: () => provider.cargarSolicitudes(),
              color: AppColors.naranjaBCP,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tarjeta Comisión Acumulada
                    _buildComisionesCard(comisionAcumulada),
                    const SizedBox(height: 20),

                    // Avance de Colocación (Dinero desembolsado)
                    _buildMetaProgressCard(
                      title: 'Meta de Colocación del Mes',
                      label: 'Volumen Desembolsado',
                      valueStr: 'S/ ${avanceColocacion.toStringAsFixed(2)} / S/ ${metaColocacion.toStringAsFixed(0)}',
                      porcentaje: porcentajeColocacion,
                      activeColor: AppColors.azulPrincipal,
                      icon: Icons.monetization_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    // Avance de Expedientes aprobados
                    _buildMetaProgressCard(
                      title: 'Meta de Solicitudes Aprobadas',
                      label: 'Expedientes Calificados',
                      valueStr: '$avanceExpedientes / $metaExpedientes solicitudes',
                      porcentaje: porcentajeExpedientes,
                      activeColor: AppColors.naranjaBCP,
                      icon: Icons.assignment_turned_in_outlined,
                    ),
                    const SizedBox(height: 24),

                    // Leyenda / Tips de productividad
                    Card(
                      color: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline, color: AppColors.naranjaBCP, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Consejo: Realice visitas preventivas en cartera diaria y use el simulador de TEA para negociar mejores tasas con clientes de perfil preferencial.',
                                style: TextStyle(color: AppColors.grisTexto, fontSize: 12.5, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildComisionesCard(double totalComisiones) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.azulPrincipal, AppColors.azulSecundario],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: const Icon(Icons.stars, color: AppColors.naranjaBCP, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comisión Acumulada del Mes',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'S/ ${totalComisiones.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '*Equivalente al 1.0% de los créditos colocados',
                    style: TextStyle(color: Colors.white54, fontSize: 10, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaProgressCard({
    required String title,
    required String label,
    required String valueStr,
    required double porcentaje,
    required Color activeColor,
    required IconData icon,
  }) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: activeColor, size: 22),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.azulPrincipal),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                Text(
                  valueStr,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: activeColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: porcentaje,
                minHeight: 12,
                backgroundColor: const Color(0xFFEDEFF3),
                valueColor: AlwaysStoppedAnimation(activeColor),
              ),
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Avance: ${(porcentaje * 100).toStringAsFixed(0)}%',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.grisTexto),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
