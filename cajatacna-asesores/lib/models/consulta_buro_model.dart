class ConsultaBuro {
  final String id;
  final String asesorId;
  final String clienteId;
  final String dniConsultado;
  final String calificacionSbs;
  final int entidadesConDeuda;
  final double deudaTotalPen;
  final double mayorDeuda;
  final int diasMayorMora;
  final bool enListaNegra;
  final String? motivoBloqueo;
  final int scoreSentinel;
  final String riesgo;
  final DateTime createdAt;

  ConsultaBuro({
    required this.id,
    required this.asesorId,
    required this.clienteId,
    required this.dniConsultado,
    required this.calificacionSbs,
    required this.entidadesConDeuda,
    required this.deudaTotalPen,
    required this.mayorDeuda,
    required this.diasMayorMora,
    required this.enListaNegra,
    this.motivoBloqueo,
    required this.scoreSentinel,
    required this.riesgo,
    required this.createdAt,
  });

  factory ConsultaBuro.fromJson(Map<String, dynamic> json) => ConsultaBuro(
    id: json['id']?.toString() ?? '',
    asesorId: json['asesor_id']?.toString() ?? '',
    clienteId: json['cliente_id']?.toString() ?? '',
    dniConsultado: json['dni_consultado']?.toString() ?? '',
    calificacionSbs: json['calificacion_sbs']?.toString() ?? 'Normal',
    entidadesConDeuda: json['entidades_con_deuda'] ?? 0,
    deudaTotalPen: double.tryParse(json['deuda_total_pen']?.toString() ?? '') ?? 0.0,
    mayorDeuda: double.tryParse(json['mayor_deuda']?.toString() ?? '') ?? 0.0,
    diasMayorMora: json['dias_mayor_mora'] ?? 0,
    enListaNegra: json['en_lista_negra'] ?? false,
    motivoBloqueo: json['motivo_bloqueo']?.toString(),
    scoreSentinel: json['score_sentinel'] ?? 700,
    riesgo: json['riesgo']?.toString() ?? 'Bajo',
    createdAt: json['created_at'] != null
        ? DateTime.parse(json['created_at'])
        : DateTime.now(),
  );

  Map<String, dynamic> toJson() => {
    'asesor_id': asesorId,
    'cliente_id': clienteId,
    'dni_consultado': dniConsultado,
    'calificacion_sbs': calificacionSbs,
    'entidades_con_deuda': entidadesConDeuda,
    'deuda_total_pen': deudaTotalPen,
    'mayor_deuda': mayorDeuda,
    'dias_mayor_mora': diasMayorMora,
    'en_lista_negra': enListaNegra,
    'motivo_bloqueo': motivoBloqueo,
    'score_sentinel': scoreSentinel,
    'riesgo': riesgo,
  };
}
