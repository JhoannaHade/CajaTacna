import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/credito_provider.dart';
import '../widgets/app_scaffold.dart';

class CreditosScreen extends StatefulWidget {
  const CreditosScreen({super.key});

  @override
  State<CreditosScreen> createState() => _CreditosScreenState();
}

class _CreditosScreenState extends State<CreditosScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CreditoProvider>().cargarCreditos('user-id');
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Créditos',
      currentIndex: 0,
      body: Consumer<CreditoProvider>(
        builder: (context, creditoProvider, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (creditoProvider.creditos.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: creditoProvider.creditos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final credito = creditoProvider.creditos[index];
                        return Card(
                          child: ListTile(
                            title: Text(credito.id),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: credito.progreso,
                                  backgroundColor: Colors.grey[300],
                                  valueColor:
                                      const AlwaysStoppedAnimation(
                                        AppColors.naranjaBCP,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${credito.cuotasPagadas} de ${credito.cuotas} cuotas',
                                  style: const TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            onTap: () {
                              context
                                  .read<CreditoProvider>()
                                  .cargarCronograma(credito.id);
                              _mostrarCronograma(context, creditoProvider);
                            },
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _mostrarCronograma(
    BuildContext context,
    CreditoProvider creditoProvider,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Consumer<CreditoProvider>(
          builder: (context, provider, _) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cronograma de Pagos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      itemCount: provider.cronograma.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final pago = provider.cronograma[index];
                        return ListTile(
                          title: Text(
                            'Cuota ${pago.id}',
                          ),
                          subtitle: Text(pago.fechaVencimiento),
                          trailing: Text(
                            'S/ ${pago.montoCuota.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: pago.esPagado
                                  ? AppColors.verdeExito
                                  : AppColors.rojoError,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
