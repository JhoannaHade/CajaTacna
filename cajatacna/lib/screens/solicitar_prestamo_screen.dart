import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/auth_provider.dart';
import '../providers/solicitud_provider.dart';

class SolicitarPrestamoScreen extends StatefulWidget {
  const SolicitarPrestamoScreen({super.key});

  @override
  State<SolicitarPrestamoScreen> createState() => _SolicitarPrestamoScreenState();
}

class _SolicitarPrestamoScreenState extends State<SolicitarPrestamoScreen> {
  double _monto = 5000.0;
  int _cuotas = 12;
  String _motivo = 'Capital de trabajo: compra de mercaderia';
  final _motivoController = TextEditingController();
  bool _customMotivo = false;

  // Crédito Empresarial fields
  bool _seguroDesgravamen = true;
  String _garantia = 'sin garantia';

  final List<int> _plazos = [12, 18, 24, 36];
  final List<String> _motivosPredeterminados = [
    'Capital de trabajo: compra de mercaderia',
    'Compra de cocina industrial',
    'Maquinaria: sierra y cepillo',
    'Reposicion de stock por campana',
    'Ampliacion de local',
    'Compra de maquinas remalladoras',
    'Cuota inicial de vehiculo de carga',
    'Ampliacion de galpon',
    'Capital para nueva sucursal',
    'Equipamiento y stock farmaceutico',
    'Compra de congeladora',
    'Mobiliario y equipos de salon',
    'Horno rotativo',
    'Herramienta neumatica',
    'Capital para campana agricola',
    'Compra de cuero y maquinaria',
    'Reposicion de inventario mayorista',
    'Ampliacion y remodelacion',
    'Compra de stock estructural',
    'Maquinaria de tejido plano',
    'Cuota inicial de camion',
    'Equipamiento de planta',
    'Compra de vitrinas',
    'Capital de trabajo',
    'Ampliacion de local nuevo',
    'Maquinaria de mayor capacidad',
    'Compra de stock y montacarga',
    'Compra de camioneta para reparto',
    'Compra de unidad de transporte',
    'Otros (Especificar)',
  ];

  final List<String> _garantias = [
    'sin garantia',
    'hipotecaria',
    'vehicular',
    'aval',
  ];

  @override
  void dispose() {
    _motivoController.dispose();
    super.dispose();
  }

  double _calcularCuotaEstimada() {
    final double tea = _seguroDesgravamen ? 0.4092 : 0.4392;
    final double tem = pow(1 + tea, 1 / 12) - 1;
    
    // PMT = P * (r * (1+r)^n) / ((1+r)^n - 1)
    final double pmt = _monto * 
        (tem * pow(1 + tem, _cuotas)) / 
        (pow(1 + tem, _cuotas) - 1);
    
    return pmt;
  }

  Future<void> _enviarSolicitud() async {
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró sesión activa.')),
      );
      return;
    }

    final motivoFinal = _customMotivo ? _motivoController.text : _motivo;
    if (motivoFinal.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, indica el motivo del préstamo.')),
      );
      return;
    }

    // Generar expediente aleatorio EXP-XXXXXX
    final random = Random();
    final numeroExpediente = 'EXP-${100000 + random.nextInt(900000)}';
    final teaSelected = _seguroDesgravamen ? 40.92 : 43.92;

    final success = await context.read<SolicitudProvider>().crearSolicitud(
      userId: userId,
      monto: _monto,
      cuotas: _cuotas,
      motivo: motivoFinal,
      garantia: _garantia,
      seguroDesgravamen: _seguroDesgravamen,
      tasaInteres: teaSelected,
      numeroExpediente: numeroExpediente,
    );

    if (success && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.verdeExito, size: 28),
              SizedBox(width: 8),
              Text(
                '¡Solicitud Enviada!',
                style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulPrincipal),
              ),
            ],
          ),
          content: Text(
            'Tu solicitud de Crédito Empresarial por S/ ${_monto.toStringAsFixed(2)} a $_cuotas meses ha sido registrada con éxito.\n\n'
            '• Expediente: $numeroExpediente\n'
            '• TEA: ${teaSelected.toStringAsFixed(2)}%\n'
            '• Garantía: $_garantia\n\n'
            'El expediente se encolará y asignará al asesor de negocios para su evaluación en campo.',
            style: const TextStyle(fontSize: 14, color: AppColors.grisTexto, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx); // Cerrar diálogo
                Navigator.pop(context, true); // Regresar a pantalla de préstamos
              },
              child: const Text(
                'Entendido',
                style: TextStyle(color: AppColors.naranjaBCP, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      );
    } else if (mounted) {
      final error = context.read<SolicitudProvider>().error ?? 'Ocurrió un error inesperado.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.rojoError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cuotaEstimada = _calcularCuotaEstimada();
    final provider = context.watch<SolicitudProvider>();
    final teaSelected = _seguroDesgravamen ? 40.92 : 43.92;

    return Scaffold(
      backgroundColor: AppColors.fondoGrisClaro,
      appBar: AppBar(
        title: const Text(
          'Solicitar Crédito Empresarial',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner superior de simulación
            Container(
              width: double.infinity,
              color: AppColors.azulPrincipal,
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
              child: Column(
                children: [
                  const Text(
                    'PAGO MENSUAL ESTIMADO (CUOTA FIJA)',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'S/ ${cuotaEstimada.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '*Amortización francesa. TEA: ${teaSelected.toStringAsFixed(2)}%',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            // Formulario interactivo
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta: Configurar Monto
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '¿Cuánto dinero necesitas?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColors.azulPrincipal,
                                ),
                              ),
                              Text(
                                'S/ ${_monto.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: AppColors.naranjaBCP,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Slider(
                            value: _monto,
                            min: 1000.0,
                            max: 50000.0,
                            divisions: 98, // Incrementos de S/ 500
                            activeColor: AppColors.naranjaBCP,
                            inactiveColor: const Color(0xFFEAECF0),
                            onChanged: (val) {
                              setState(() {
                                _monto = val;
                              });
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('S/ 1,000', style: TextStyle(color: AppColors.grisTexto, fontSize: 11)),
                              Text('S/ 50,000', style: TextStyle(color: AppColors.grisTexto, fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta: Plazo
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¿En cuántos meses deseas pagarlo?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.azulPrincipal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: _plazos.map((meses) {
                              final isSelected = _cuotas == meses;
                              return InkWell(
                                onTap: () {
                                  setState(() {
                                    _cuotas = meses;
                                  });
                                },
                                child: Container(
                                  width: 64,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppColors.azulPrincipal : Colors.white,
                                    border: Border.all(
                                      color: isSelected ? AppColors.azulPrincipal : const Color(0xFFD0D5DD),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '$meses\nmeses',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : AppColors.azulPrincipal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta: Seguro de Desgravamen
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Seguro de Desgravamen',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: AppColors.azulPrincipal,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Protege tu crédito en caso de siniestro',
                                    style: TextStyle(color: AppColors.grisTexto, fontSize: 11),
                                  ),
                                ],
                              ),
                              Switch(
                                value: _seguroDesgravamen,
                                activeColor: AppColors.naranjaBCP,
                                onChanged: (val) {
                                  setState(() {
                                    _seguroDesgravamen = val;
                                  });
                                },
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            _seguroDesgravamen
                                ? '• Tasa aplicada: 40.92% TEA (Con Seguro de Desgravamen)'
                                : '• Tasa aplicada: 43.92% TEA (Sin Seguro de Desgravamen)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _seguroDesgravamen ? Colors.green[700] : Colors.blueGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta: Tipo de Garantía
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Garantía ofrecida',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.azulPrincipal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _garantia,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                            ),
                            items: _garantias.map((g) {
                              return DropdownMenuItem<String>(
                                value: g,
                                child: Text(g.toUpperCase(), style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _garantia = val;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Tarjeta: Motivo
                  Card(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¿Cuál es el destino del dinero?',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.azulPrincipal,
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _motivo,
                            isExpanded: true,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                              ),
                            ),
                            items: _motivosPredeterminados.map((mot) {
                              return DropdownMenuItem<String>(
                                value: mot,
                                child: Text(
                                  mot, 
                                  style: const TextStyle(fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _motivo = val;
                                  _customMotivo = val.startsWith('Otros');
                                });
                              }
                            },
                          ),
                          if (_customMotivo) ...[
                            const SizedBox(height: 12),
                            TextField(
                              controller: _motivoController,
                              maxLines: 2,
                              decoration: InputDecoration(
                                hintText: 'Describe brevemente el motivo del préstamo...',
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón Enviar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _enviarSolicitud,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.naranjaBCP,
                        disabledBackgroundColor: const Color(0xFFEDEFF3),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: const Color(0xFFC5CAD3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        elevation: 0,
                      ),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Text(
                              'Enviar Solicitud',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
