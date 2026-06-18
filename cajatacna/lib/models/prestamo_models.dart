class Prestamo {
  final String id;
  final String userId;
  final String tipo;
  final String numeroEnmascarado;
  final double capitalTotal;
  final double capitalPendiente;
  final int cuotaNumero;
  final int cuotasTotal;
  final String fechaLimite;
  final double capitalCuota;
  final double interesesCuota;
  final double seguurosCuota;

  Prestamo({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.numeroEnmascarado,
    required this.capitalTotal,
    required this.capitalPendiente,
    required this.cuotaNumero,
    required this.cuotasTotal,
    required this.fechaLimite,
    required this.capitalCuota,
    required this.interesesCuota,
    required this.seguurosCuota,
  });

  double get totalCuota => capitalCuota + interesesCuota + seguurosCuota;

  double get progreso {
    if (cuotasTotal == 0) return 0;
    return (cuotaNumero - 1) / cuotasTotal;
  }

  factory Prestamo.fromJson(Map<String, dynamic> json) => Prestamo(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    tipo: json['tipo'] ?? '',
    numeroEnmascarado: json['numero_enmascarado'] ?? '',
    capitalTotal: (json['capital_total'] ?? 0.0).toDouble(),
    capitalPendiente: (json['capital_pendiente'] ?? 0.0).toDouble(),
    cuotaNumero: json['cuota_numero'] ?? 0,
    cuotasTotal: json['cuotas_total'] ?? 0,
    fechaLimite: json['fecha_limite'] ?? '',
    capitalCuota: (json['capital_cuota'] ?? 0.0).toDouble(),
    interesesCuota: (json['intereses_cuota'] ?? 0.0).toDouble(),
    seguurosCuota: (json['seguros_cuota'] ?? 0.0).toDouble(),
  );
}
