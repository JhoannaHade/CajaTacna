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
  final double segurosCuota;
  final String? clienteNombre;
  final String? clienteDni;

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
    required this.segurosCuota,
    this.clienteNombre,
    this.clienteDni,
  });

  factory Prestamo.fromJson(Map<String, dynamic> json) => Prestamo(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    tipo: json['tipo']?.toString() ?? 'Préstamo',
    numeroEnmascarado: json['numero_enmascarado']?.toString() ?? '',
    capitalTotal: double.tryParse(json['capital_total']?.toString() ?? '') ?? 0.0,
    capitalPendiente: double.tryParse(json['capital_pendiente']?.toString() ?? '') ?? 0.0,
    cuotaNumero: json['cuota_numero'] ?? 1,
    cuotasTotal: json['cuotas_total'] ?? 12,
    fechaLimite: json['fecha_limite']?.toString() ?? '',
    capitalCuota: double.tryParse(json['capital_cuota']?.toString() ?? '') ?? 0.0,
    interesesCuota: double.tryParse(json['intereses_cuota']?.toString() ?? '') ?? 0.0,
    segurosCuota: double.tryParse(json['seguros_cuota']?.toString() ?? '') ?? 0.0,
    clienteNombre: json['perfiles']?['nombre_completo']?.toString(),
    clienteDni: json['perfiles']?['numero_documento']?.toString(),
  );
}
