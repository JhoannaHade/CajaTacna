class AccionCobranza {
  final String id;
  final String asesorId;
  final String clienteId;
  final String tipoGestion;
  final String resultado;
  final double montoPagado;
  final String? fechaCompromiso;
  final double montoCompromiso;
  final String observaciones;
  final DateTime timestampGestion;

  AccionCobranza({
    required this.id,
    required this.asesorId,
    required this.clienteId,
    required this.tipoGestion,
    required this.resultado,
    required this.montoPagado,
    this.fechaCompromiso,
    required this.montoCompromiso,
    required this.observaciones,
    required this.timestampGestion,
  });

  factory AccionCobranza.fromJson(Map<String, dynamic> json) => AccionCobranza(
    id: json['id']?.toString() ?? '',
    asesorId: json['asesor_id']?.toString() ?? '',
    clienteId: json['cliente_id']?.toString() ?? '',
    tipoGestion: json['tipo_gestion']?.toString() ?? 'llamada',
    resultado: json['resultado']?.toString() ?? 'compromiso_pago',
    montoPagado: double.tryParse(json['monto_pagado']?.toString() ?? '') ?? 0.0,
    fechaCompromiso: json['fecha_compromiso']?.toString(),
    montoCompromiso: double.tryParse(json['monto_compromiso']?.toString() ?? '') ?? 0.0,
    observaciones: json['observaciones']?.toString() ?? '',
    timestampGestion: json['timestamp_gestion'] != null
        ? DateTime.parse(json['timestamp_gestion'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'asesor_id': asesorId,
    'cliente_id': clienteId,
    'tipo_gestion': tipoGestion,
    'resultado': resultado,
    'monto_pagado': montoPagado,
    'fecha_compromiso': fechaCompromiso,
    'monto_compromiso': montoCompromiso,
    'observaciones': observaciones,
  };
}
