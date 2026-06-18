class CarteraDiaria {
  final String id;
  final String asesorId;
  final String clienteId;
  final String fechaAsignacion;
  final String tipoGestion;
  final String prioridad;
  final int scorePrioridad;
  final String estadoVisita;
  final String? resultadoVisita;
  final String? observacionVisita;
  final DateTime? timestampVisita;
  final double? latVisita;
  final double? lngVisita;
  final double montoCredito;
  final String? clienteNombre;
  final String? clienteDni;
  final String? clienteTelefono;
  final String? clienteDireccion;

  CarteraDiaria({
    required this.id,
    required this.asesorId,
    required this.clienteId,
    required this.fechaAsignacion,
    required this.tipoGestion,
    required this.prioridad,
    required this.scorePrioridad,
    required this.estadoVisita,
    this.resultadoVisita,
    this.observacionVisita,
    this.timestampVisita,
    this.latVisita,
    this.lngVisita,
    required this.montoCredito,
    this.clienteNombre,
    this.clienteDni,
    this.clienteTelefono,
    this.clienteDireccion,
  });

  factory CarteraDiaria.fromJson(Map<String, dynamic> json) => CarteraDiaria(
    id: json['id']?.toString() ?? '',
    asesorId: json['asesor_id']?.toString() ?? '',
    clienteId: json['cliente_id']?.toString() ?? '',
    fechaAsignacion: json['fecha_asignacion']?.toString() ?? '',
    tipoGestion: json['tipo_gestion']?.toString() ?? 'SEGUIMIENTO',
    prioridad: json['prioridad']?.toString() ?? 'Media',
    scorePrioridad: json['score_prioridad'] ?? 50,
    estadoVisita: json['estado_visita']?.toString() ?? 'pendiente',
    resultadoVisita: json['resultado_visita']?.toString(),
    observacionVisita: json['observacion_visita']?.toString(),
    timestampVisita: json['timestamp_visita'] != null
        ? DateTime.parse(json['timestamp_visita'])
        : null,
    latVisita: json['lat_visita'] != null ? double.tryParse(json['lat_visita'].toString()) : null,
    lngVisita: json['lng_visita'] != null ? double.tryParse(json['lng_visita'].toString()) : null,
    montoCredito: double.tryParse(json['monto_credito']?.toString() ?? '') ?? 5000.0,
    clienteNombre: json['perfiles']?['nombre_completo']?.toString(),
    clienteDni: json['perfiles']?['numero_documento']?.toString(),
    clienteTelefono: json['perfiles']?['telefono']?.toString(),
    clienteDireccion: json['perfiles']?['direccion']?.toString(),
  );

  Map<String, dynamic> toJson() => {
    'asesor_id': asesorId,
    'cliente_id': clienteId,
    'tipo_gestion': tipoGestion,
    'prioridad': prioridad,
    'score_prioridad': scorePrioridad,
    'estado_visita': estadoVisita,
    'monto_credito': montoCredito,
  };
}
