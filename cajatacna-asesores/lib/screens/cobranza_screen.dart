import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/cobranza_provider.dart';
import '../models/prestamo_model.dart';
import '../widgets/advisor_drawer.dart';

class CobranzaScreen extends StatefulWidget {
  const CobranzaScreen({super.key});

  @override
  State<CobranzaScreen> createState() => _CobranzaScreenState();
}

class _CobranzaScreenState extends State<CobranzaScreen> {
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
    context.read<CobranzaProvider>().cargarPrestamosEnMora();
  }

  void _mostrarDetalleCobranza(Prestamo prestamo) {
    final tipoController = TextEditingController(text: 'llamada');
    final resultadoController = TextEditingController(text: 'compromiso_pago');
    final montoPagadoController = TextEditingController(text: '0');
    final montoCompromisoController = TextEditingController(text: '0');
    final observacionesController = TextEditingController();
    String fechaCompromisoStr = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setStateModal) => Padding(
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
                      'Gestión de Cobranza',
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
                
                // Datos del préstamo y mora
                Text(
                  prestamo.clienteNombre ?? 'Cliente Caja Tacna',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulOscuro),
                ),
                const SizedBox(height: 4),
                Text('DNI: ${prestamo.clienteDni ?? "N/A"}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 13)),
                const SizedBox(height: 4),
                Text('Préstamo: ${prestamo.numeroEnmascarado}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 13)),
                const SizedBox(height: 4),
                Text(
                  'Saldo Pendiente: S/ ${prestamo.capitalPendiente.toStringAsFixed(2)}',
                  style: const TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                
                const Divider(height: 24),
                
                // Formulario de acción
                const Text(
                  'Registrar Gestión de Cobro',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.azulPrincipal),
                ),
                const SizedBox(height: 12),
                
                // Tipo de gestión
                DropdownButtonFormField<String>(
                  value: tipoController.text,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Contacto',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'llamada', child: Text('Llamada Telefónica')),
                    DropdownMenuItem(value: 'visita', child: Text('Visita Domiciliaria')),
                    DropdownMenuItem(value: 'mensaje', child: Text('Mensaje de Texto / WhatsApp')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      tipoController.text = val;
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // Resultado de gestión
                DropdownButtonFormField<String>(
                  value: resultadoController.text,
                  decoration: const InputDecoration(
                    labelText: 'Resultado de Gestión',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'compromiso_pago', child: Text('Compromiso de Pago')),
                    DropdownMenuItem(value: 'pago_parcial', child: Text('Pago Parcial Registrado')),
                    DropdownMenuItem(value: 'sin_contacto', child: Text('Sin Contacto')),
                    DropdownMenuItem(value: 'se_niega', child: Text('Se Niega a Pagar')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setStateModal(() {
                        resultadoController.text = val;
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                
                // Si el resultado es compromiso de pago o pago parcial
                if (resultadoController.text == 'compromiso_pago') ...[
                  TextField(
                    controller: montoCompromisoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto de Compromiso (S/)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Selector de fecha de compromiso
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          fechaCompromisoStr.isEmpty
                              ? 'Seleccionar Fecha de Compromiso'
                              : 'Fecha: $fechaCompromisoStr',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: fechaCompromisoStr.isEmpty ? AppColors.grisTexto : AppColors.azulPrincipal,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now().add(const Duration(days: 1)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 60)),
                          );
                          if (date != null) {
                            setStateModal(() {
                              fechaCompromisoStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.azulPrincipal),
                        child: const Text('Calendario', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ] else if (resultadoController.text == 'pago_parcial') ...[
                  TextField(
                    controller: montoPagadoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto de Pago Recibido (S/)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                TextField(
                  controller: observacionesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones / Detalles de Gestión',
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
                        final success = await context.read<CobranzaProvider>().registrarGestion(
                          advisorUserId: advisorId,
                          clientUserId: prestamo.userId,
                          tipoGestion: tipoController.text,
                          resultado: resultadoController.text,
                          montoPagado: double.tryParse(montoPagadoController.text) ?? 0.0,
                          fechaCompromiso: fechaCompromisoStr.isNotEmpty ? fechaCompromisoStr : null,
                          montoCompromiso: double.tryParse(montoCompromisoController.text) ?? 0.0,
                          observaciones: observacionesController.text,
                        );
                        if (success && mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Gestión de cobranza registrada'), backgroundColor: AppColors.verdeExito),
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
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CobranzaProvider>();

    return Scaffold(
      backgroundColor: AppColors.fondoGrisClaro,
      drawer: const AdvisorDrawer(currentRoute: AppRoutes.cobranza),
      appBar: AppBar(
        title: const Text(
          'Gestión de Cobranzas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.azulPrincipal,
        elevation: 0,
      ),
      body: provider.isLoading && provider.prestamosEnMora.isEmpty
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
              : provider.prestamosEnMora.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.thumb_up_alt_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No hay préstamos vencidos en cartera', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      color: AppColors.naranjaBCP,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.prestamosEnMora.length,
                        itemBuilder: (context, index) {
                          final prestamo = provider.prestamosEnMora[index];
                          return _CobranzaCard(
                            prestamo: prestamo,
                            onTap: () => _mostrarDetalleCobranza(prestamo),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _CobranzaCard extends StatelessWidget {
  final Prestamo prestamo;
  final VoidCallback onTap;

  const _CobranzaCard({required this.prestamo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
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
                  CircleAvatar(
                    backgroundColor: AppColors.rojoError.withOpacity(0.08),
                    radius: 20,
                    child: const Icon(Icons.warning_amber_outlined, color: AppColors.rojoError),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prestamo.clienteNombre ?? 'Cliente Caja Tacna',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.azulOscuro),
                        ),
                        const SizedBox(height: 2),
                        Text('DNI: ${prestamo.clienteDni ?? "N/A"}', style: const TextStyle(color: AppColors.grisTexto, fontSize: 12)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.rojoError.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '1 Cuota Vencida',
                      style: TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monto en Mora', style: TextStyle(color: AppColors.grisTexto, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        'S/ ${(prestamo.capitalPendiente * 0.08).toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Saldo Restante', style: TextStyle(color: AppColors.grisTexto, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(
                        'S/ ${prestamo.capitalPendiente.toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.azulPrincipal, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
