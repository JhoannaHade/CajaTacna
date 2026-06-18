import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/cartera_provider.dart';
import '../models/cartera_diaria_model.dart';
import '../widgets/advisor_drawer.dart';

class CarteraScreen extends StatefulWidget {
  const CarteraScreen({super.key});

  @override
  State<CarteraScreen> createState() => _CarteraScreenState();
}

class _CarteraScreenState extends State<CarteraScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _loadData();
      _initialized = true;
    }
  }

  Future<void> _loadData() async {
    final advisorId = context.read<AuthProvider>().currentUser?.id;
    if (advisorId != null) {
      context.read<CarteraProvider>().cargarCartera(advisorId);
    }
  }

  void _mostrarDetalleVisita(CarteraDiaria visita) {
    final resultadoController = TextEditingController(text: 'compromiso_pago');
    final observacionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detalle de la Gestión',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.azulPrincipal),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),
              
              // Datos del cliente
              Text(
                visita.clienteNombre ?? 'Cliente Caja Tacna',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulOscuro),
              ),
              const SizedBox(height: 4),
              Text('DNI: ${visita.clienteDni ?? "N/A"}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Dirección: ${visita.clienteDireccion ?? "No registrada"}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Teléfono: ${visita.clienteTelefono ?? "No registrado"}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 13)),
              
              const SizedBox(height: 12),
              Row(
                children: [
                  Chip(
                    label: Text(visita.tipoGestion, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
                    backgroundColor: AppColors.azulPrincipal,
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text('Prioridad ${visita.prioridad}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 11)),
                    backgroundColor: visita.prioridad == 'Alta' ? AppColors.rojoError : AppColors.naranjaAviso,
                  ),
                ],
              ),
              
              const Divider(height: 24),
              
              if (visita.estadoVisita == 'visitado') ...[
                // Mostrar datos de visita realizada
                const Text('Gestión Realizada', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.azulPrincipal)),
                const SizedBox(height: 8),
                _buildInfoRow('Resultado:', visita.resultadoVisita ?? 'compromiso_pago'),
                const SizedBox(height: 6),
                _buildInfoRow('Observaciones:', visita.observacionVisita ?? 'Sin observaciones.'),
                const SizedBox(height: 24),
              ] else ...[
                // Formulario para registrar visita
                const Text(
                  'Registrar Resultado de Visita',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.azulPrincipal),
                ),
                const SizedBox(height: 12),
                
                DropdownButtonFormField<String>(
                  value: resultadoController.text,
                  decoration: const InputDecoration(
                    labelText: 'Resultado de Gestión',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'compromiso_pago', child: Text('Compromiso de Pago')),
                    DropdownMenuItem(value: 'pago_parcial', child: Text('Pago Parcial Realizado')),
                    DropdownMenuItem(value: 'sin_contacto', child: Text('Cliente no Encontrado / Sin Contacto')),
                    DropdownMenuItem(value: 'se_niega', child: Text('Se Niega a Pagar / Negativa')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      resultadoController.text = val;
                    }
                  },
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: observacionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notas / Observaciones de la Visita',
                    hintText: 'Ingrese detalles de la reunión con el cliente...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      final advisorId = context.read<AuthProvider>().currentUser?.id;
                      if (advisorId != null) {
                        Navigator.pop(ctx);
                        final success = await context.read<CarteraProvider>().registrarVisita(
                          id: visita.id,
                          resultado: resultadoController.text,
                          observacion: observacionController.text,
                          advisorUserId: advisorId,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Visita registrada con éxito'), backgroundColor: AppColors.verdeExito),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.azulPrincipal,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Guardar Gestión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.grisTexto)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarteraProvider>();
    
    return Scaffold(
      backgroundColor: AppColors.fondoGrisClaro,
      drawer: const AdvisorDrawer(currentRoute: AppRoutes.cartera),
      appBar: AppBar(
        title: const Text(
          'Cartera de Visitas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.azulPrincipal,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Resumen rápido
          Container(
            color: AppColors.azulPrincipal,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                _buildStatTile('Pendientes', '${provider.pendientesCount}', AppColors.naranjaBCP),
                const SizedBox(width: 16),
                _buildStatTile('Gestionadas', '${provider.visitadosCount}', AppColors.verdeExito),
              ],
            ),
          ),
          
          Expanded(
            child: provider.isLoading && provider.visitas.isEmpty
                ? const Center(child: CircularProgressIndicator(color: AppColors.naranjaBCP))
                : provider.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(provider.error!, style: const TextStyle(color: AppColors.rojoError)),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: _loadData,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulPrincipal),
                              child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      )
                    : provider.visitas.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.location_off_outlined, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text('No tienes visitas programadas para hoy', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadData,
                            color: AppColors.naranjaBCP,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.visitas.length,
                              itemBuilder: (context, index) {
                                final visita = provider.visitas[index];
                                return _VisitaCard(
                                  visita: visita,
                                  onTap: () => _mostrarDetalleVisita(visita),
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _VisitaCard extends StatelessWidget {
  final CarteraDiaria visita;
  final VoidCallback onTap;

  const _VisitaCard({required this.visita, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDone = visita.estadoVisita == 'visitado';
    final priorityColor = visita.prioridad == 'Alta' ? AppColors.rojoError : AppColors.naranjaAviso;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isDone ? AppColors.verdeExito.withOpacity(0.1) : AppColors.azulPrincipal.withOpacity(0.06),
                radius: 22,
                child: Icon(
                  isDone ? Icons.check_circle_outline : Icons.location_on_outlined,
                  color: isDone ? AppColors.verdeExito : AppColors.azulPrincipal,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visita.clienteNombre ?? 'Cliente Caja Tacna',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.azulOscuro),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8.0,
                      children: [
                        Text('DNI: ${visita.clienteDni ?? ""}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                        const Text('•', style: TextStyle(color: Colors.grey)),
                        Text(visita.tipoGestion, style: const TextStyle(color: AppColors.azulSecundario, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      visita.prioridad,
                      style: TextStyle(color: priorityColor, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'S/ ${visita.montoCredito.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.azulPrincipal),
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
