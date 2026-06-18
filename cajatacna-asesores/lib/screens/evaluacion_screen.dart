import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';
import '../providers/buro_provider.dart';
import '../models/consulta_buro_model.dart';
import '../widgets/advisor_drawer.dart';

class EvaluacionScreen extends StatefulWidget {
  const EvaluacionScreen({super.key});

  @override
  State<EvaluacionScreen> createState() => _EvaluacionScreenState();
}

class _EvaluacionScreenState extends State<EvaluacionScreen> {
  final _dniController = TextEditingController();
  final _ingresosController = TextEditingController();
  final _montoController = TextEditingController();
  
  String? _selectedClientId;
  int _cuotas = 12;
  bool _evaluated = false;
  
  // Resultados locales de la pre-evaluación
  bool _aprobado = false;
  double _capacidadPago = 0.0;
  String _dictamen = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BuroProvider>().cargarClientes();
    });
  }

  @override
  void dispose() {
    _dniController.dispose();
    _ingresosController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  void _ejecutarPreEvaluacion(ConsultaBuro buro) {
    final ingresos = double.tryParse(_ingresosController.text) ?? 0.0;
    final monto = double.tryParse(_montoController.text) ?? 0.0;
    final cuota = (monto * 1.15) / _cuotas; // Simula recargo financiero del 15%
    final capacidad = (ingresos * 0.40) - cuota; // Capacidad máxima del 40% del ingreso

    setState(() {
      _capacidadPago = capacidad > 0 ? capacidad : 0.0;
      _aprobado = capacidad > 0 && !buro.enListaNegra && buro.scoreSentinel > 600;

      if (buro.enListaNegra) {
        _dictamen = 'RECHAZADO: El cliente se encuentra reportado en la lista negra del buró financiero.';
      } else if (buro.scoreSentinel <= 600) {
        _dictamen = 'RECHAZADO: Score crediticio deficiente. Sentinel reporta alto riesgo.';
      } else if (capacidad <= 0) {
        _dictamen = 'RECHAZADO: Capacidad de pago insuficiente para soportar la cuota estimada de S/ ${cuota.toStringAsFixed(2)}.';
      } else {
        _dictamen = 'APROBADO: El solicitante califica para el préstamo con capacidad de pago óptima y bajo riesgo.';
      }
      
      _evaluated = true;
    });
  }

  Future<void> _consultarBuroYPreEvaluar() async {
    if (_dniController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingrese el DNI del cliente.')),
      );
      return;
    }
    if (_ingresosController.text.trim().isEmpty || _montoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, complete los ingresos y el monto solicitado.')),
      );
      return;
    }

    final advisorId = context.read<AuthProvider>().currentUser?.id;
    if (advisorId == null) return;

    final provider = context.read<BuroProvider>();
    
    // Obtener el ID del cliente correspondiente al DNI o usar el seleccionado
    String clientUserId = _selectedClientId ?? advisorId; 
    if (_selectedClientId == null) {
      final matches = provider.clientes.where((c) => c['numero_documento'] == _dniController.text).toList();
      if (matches.isNotEmpty) {
        clientUserId = matches.first['user_id'] ?? advisorId;
      }
    }

    await provider.consultarBuro(
      advisorUserId: advisorId,
      clientUserId: clientUserId,
      dni: _dniController.text.trim(),
    );

    if (provider.consultaActual != null) {
      _ejecutarPreEvaluacion(provider.consultaActual!);
    } else if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error!), backgroundColor: AppColors.rojoError),
      );
    }
  }

  void _limpiarFormulario() {
    setState(() {
      _dniController.clear();
      _ingresosController.clear();
      _montoController.clear();
      _selectedClientId = null;
      _cuotas = 12;
      _evaluated = false;
    });
    context.read<BuroProvider>().limpiarConsulta();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BuroProvider>();

    return Scaffold(
      backgroundColor: AppColors.fondoGrisClaro,
      drawer: const AdvisorDrawer(currentRoute: AppRoutes.evaluacion),
      appBar: AppBar(
        title: const Text(
          'Pre-evaluación / Buró',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.azulPrincipal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Formulario
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Datos de Evaluación Financiera',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulPrincipal),
                    ),
                    const Divider(height: 24),
                    
                    // Selector de clientes rápidos
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      value: _selectedClientId,
                      decoration: const InputDecoration(
                        labelText: 'Seleccionar Cliente Registrado',
                        hintText: 'Buscar cliente...',
                        border: OutlineInputBorder(),
                      ),
                      items: provider.clientes.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['user_id']?.toString(),
                          child: Text('${c['nombre_completo']} (${c['numero_documento']})', style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final cl = provider.clientes.firstWhere((c) => c['user_id'] == val);
                          setState(() {
                            _selectedClientId = val;
                            _dniController.text = cl['numero_documento'] ?? '';
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    // Campo DNI manual
                    TextField(
                      controller: _dniController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Número de DNI del Solicitante',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ingresosController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Ingresos Mensuales (S/)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.monetization_on_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _montoController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: const InputDecoration(
                              labelText: 'Monto de Crédito (S/)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Selector de cuotas
                    const Text('Plazo solicitado:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.grisTexto)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: [12, 18, 24, 36].map((meses) {
                        final isSelected = _cuotas == meses;
                        return ChoiceChip(
                          label: Text('$meses meses'),
                          selected: isSelected,
                          selectedColor: AppColors.azulPrincipal,
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.azulPrincipal,
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _cuotas = meses;
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _limpiarFormulario,
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.azulPrincipal),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text('Limpiar', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.azulPrincipal)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: provider.isLoading ? null : _consultarBuroYPreEvaluar,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.naranjaBCP,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: provider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                  )
                                : const Text('Pre-evaluar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Resultados de Buró y Evaluación
            if (_evaluated && provider.consultaActual != null) ...[
              _buildResultPanel(provider.consultaActual!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(ConsultaBuro buro) {
    final statusColor = _aprobado ? AppColors.verdeExito : AppColors.rojoError;
    final riskColor = buro.riesgo == 'Bajo'
        ? AppColors.verdeExito
        : buro.riesgo == 'Medio'
            ? AppColors.naranjaAviso
            : AppColors.rojoError;

    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dictamen e Historial Crediticio',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.azulPrincipal),
            ),
            const Divider(height: 24),
            
            // Caja de Aprobación
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(_aprobado ? Icons.check_circle : Icons.cancel, color: statusColor, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _aprobado ? 'APROBADO PRELIMINAR' : 'RECHAZADO SBS',
                          style: TextStyle(fontWeight: FontWeight.w900, color: statusColor, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _dictamen,
                          style: const TextStyle(fontSize: 13, color: AppColors.grisTexto, height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Score e info del buró
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Score Sentinel',
                    '${buro.scoreSentinel}',
                    Icons.speed,
                    riskColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    'Clasificación SBS',
                    buro.calificacionSbs,
                    Icons.assignment_ind_outlined,
                    AppColors.azulPrincipal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(
                    'Capacidad de Pago',
                    'S/ ${_capacidadPago.toStringAsFixed(2)}',
                    Icons.monetization_on_outlined,
                    AppColors.azulPrincipal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(
                    'Riesgo Estimado',
                    buro.riesgo,
                    Icons.warning_amber_outlined,
                    riskColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEAECF0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: AppColors.grisTexto, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
