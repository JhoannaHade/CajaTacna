class Credito {
  final String id;
  final String userId;
  final double monto;
  final double saldoRestante;
  final int cuotas;
  final int cuotasPagadas;
  final double tasaInteres;

  Credito({
    required this.id,
    required this.userId,
    required this.monto,
    required this.saldoRestante,
    required this.cuotas,
    required this.cuotasPagadas,
    required this.tasaInteres,
  });

  double get progreso {
    if (cuotas == 0) return 0;
    return cuotasPagadas / cuotas;
  }

  factory Credito.fromJson(Map<String, dynamic> json) => Credito(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    monto: (json['monto'] ?? 0.0).toDouble(),
    saldoRestante: (json['saldo_restante'] ?? 0.0).toDouble(),
    cuotas: json['cuotas'] ?? 0,
    cuotasPagadas: json['cuotas_pagadas'] ?? 0,
    tasaInteres: (json['tasa_interes'] ?? 0.0).toDouble(),
  );
}

class CronogramaPago {
  final String id;
  final String creditoId;
  final String fechaVencimiento;
  final double montoCuota;
  final String estado;

  CronogramaPago({
    required this.id,
    required this.creditoId,
    required this.fechaVencimiento,
    required this.montoCuota,
    required this.estado,
  });

  bool get esPagado => estado == 'pagado';

  factory CronogramaPago.fromJson(Map<String, dynamic> json) =>
      CronogramaPago(
        id: json['id']?.toString() ?? '',
        creditoId: json['credito_id']?.toString() ?? '',
        fechaVencimiento: json['fecha_vencimiento'] ?? '',
        montoCuota: (json['monto_cuota'] ?? 0.0).toDouble(),
        estado: json['estado'] ?? '',
      );
}
