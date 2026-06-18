import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/ahorro_provider.dart';
import '../widgets/app_scaffold.dart';

class AhorroScreen extends StatefulWidget {
  const AhorroScreen({super.key});

  @override
  State<AhorroScreen> createState() => _AhorroScreenState();
}

class _AhorroScreenState extends State<AhorroScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    // El userId debería pasarse, por ahora usamos un placeholder
    context.read<AhorroProvider>().cargarCuentasAhorro('user-id');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Ahorros',
      currentIndex: 0,
      body: Consumer<AhorroProvider>(
        builder: (context, ahorroProvider, _) {
          final cuenta = ahorroProvider.cuentaSeleccionada;
          return SingleChildScrollView(
            child: Column(
              children: [
                if (cuenta != null) ...[
                  _buildSaldoCard(cuenta),
                  _buildMovimientosSection(ahorroProvider),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSaldoCard(dynamic cuenta) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.azulPrincipal, AppColors.azulSecundario],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saldo Disponible',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'S/ ${cuenta.saldo.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'N° ${cuenta.numeroCuenta}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientosSection(AhorroProvider ahorroProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Movimientos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (ahorroProvider.movimientos.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Sin movimientos'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: ahorroProvider.movimientos.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final movimiento = ahorroProvider.movimientos[index];
                final esDeposito = movimiento.tipo == 'deposito';
                return ListTile(
                  leading: Icon(
                    esDeposito
                        ? Icons.arrow_downward
                        : Icons.arrow_upward,
                    color: esDeposito
                        ? AppColors.verdeExito
                        : AppColors.rojoError,
                  ),
                  title: Text(
                    movimiento.tipo.toUpperCase(),
                  ),
                  subtitle: Text(movimiento.fecha),
                  trailing: Text(
                    'S/ ${movimiento.monto.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: esDeposito
                          ? AppColors.verdeExito
                          : AppColors.rojoError,
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
