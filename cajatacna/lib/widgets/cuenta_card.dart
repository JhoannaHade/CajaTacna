import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../models/cuenta_models.dart';

class CuentaCard extends StatelessWidget {
  final Cuenta cuenta;
  final VoidCallback? onTap;

  const CuentaCard({
    required this.cuenta,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    cuenta.tipo.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.grisTexto,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.azulPrincipal),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '**** ${cuenta.numeroCuenta.substring(cuenta.numeroCuenta.length - 4)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.azulPrincipal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'S/ ${cuenta.saldo.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulPrincipal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
