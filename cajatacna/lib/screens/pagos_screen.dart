import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/network/supabase_client.dart';
import '../models/opera_models.dart';
import '../widgets/app_scaffold.dart';

class PagosScreen extends StatefulWidget {
  const PagosScreen({super.key});

  @override
  State<PagosScreen> createState() => _PagosScreenState();
}

class _PagosScreenState extends State<PagosScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _contratoController;
  late TextEditingController _montoController;
  String? _servicioSeleccionado;
  bool _isLoading = false;

  final List<String> _servicios = [
    'Luz',
    'Agua',
    'Gas',
    'Teléfono',
    'Internet',
  ];

  @override
  void initState() {
    super.initState();
    _contratoController = TextEditingController();
    _montoController = TextEditingController();
  }

  @override
  void dispose() {
    _contratoController.dispose();
    _montoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Pagos de Servicios',
      currentIndex: 0,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pagar Servicio',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _servicioSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Servicio',
                        prefixIcon: const Icon(Icons.receipt),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: _servicios.map((servicio) {
                        return DropdownMenuItem(
                          value: servicio,
                          child: Text(servicio),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _servicioSeleccionado = value);
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Seleccione un servicio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contratoController,
                      decoration: InputDecoration(
                        labelText: 'Número de Contrato',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _montoController,
                      decoration: InputDecoration(
                        labelText: 'Monto',
                        prefixIcon: const Icon(Icons.money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Campo requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingrese un monto válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _pagar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulPrincipal,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(
                                      Colors.white),
                                ),
                              )
                            : const Text(
                                'Pagar',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pagar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final pago = PagoServicioInsert(
        servicio: _servicioSeleccionado ?? '',
        contrato: _contratoController.text,
        monto: double.parse(_montoController.text),
      );

      await SupabaseClient().post(
        '/rest/v1/pagos_servicios',
        pago.toJson(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pago exitoso')),
        );
        _contratoController.clear();
        _montoController.clear();
        setState(() => _servicioSeleccionado = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
