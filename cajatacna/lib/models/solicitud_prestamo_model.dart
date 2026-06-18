class SolicitudPrestamo {
  final String id;
  final String userId;
  final double montoSolicitado;
  final int cuotas;
  final double tasaInteres;
  final String motivo;
  final String estado;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? clienteNombre;
  final String? clienteDni;

  // New fields for Crédito Empresarial
  final String? numeroExpediente;
  final String? canal;
  final String? garantia;
  final bool seguroDesgravamen;
  final double? montoAprobado;
  final String? motivoRechazo;
  final String? condicionAdicional;
  final String? firmaClienteBase64;
  final double? latCaptura;
  final double? lngCaptura;

  SolicitudPrestamo({
    required this.id,
    required this.userId,
    required this.montoSolicitado,
    required this.cuotas,
    required this.tasaInteres,
    required this.motivo,
    required this.estado,
    required this.createdAt,
    required this.updatedAt,
    this.clienteNombre,
    this.clienteDni,
    this.numeroExpediente,
    this.canal = 'cliente',
    this.garantia = 'sin garantia',
    this.seguroDesgravamen = true,
    this.montoAprobado,
    this.motivoRechazo,
    this.condicionAdicional,
    this.firmaClienteBase64,
    this.latCaptura,
    this.lngCaptura,
  });

  factory SolicitudPrestamo.fromJson(Map<String, dynamic> json) => SolicitudPrestamo(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    montoSolicitado: double.tryParse(json['monto_solicitado']?.toString() ?? '') ?? 0.0,
    cuotas: json['cuotas'] ?? 0,
    tasaInteres: double.tryParse(json['tasa_interes']?.toString() ?? '') ?? 0.0,
    motivo: json['motivo'] ?? '',
    estado: json['estado'] ?? 'pendiente',
    createdAt: json['created_at'] != null 
        ? DateTime.parse(json['created_at']) 
        : DateTime.now(),
    updatedAt: json['updated_at'] != null 
        ? DateTime.parse(json['updated_at']) 
        : DateTime.now(),
    clienteNombre: json['perfiles']?['nombre_completo']?.toString(),
    clienteDni: json['perfiles']?['numero_documento']?.toString(),
    numeroExpediente: json['numero_expediente']?.toString(),
    canal: json['canal']?.toString() ?? 'cliente',
    garantia: json['garantia']?.toString() ?? 'sin garantia',
    seguroDesgravamen: json['seguro_desgravamen'] == true,
    montoAprobado: double.tryParse(json['monto_aprobado']?.toString() ?? ''),
    motivoRechazo: json['motivo_rechazo']?.toString(),
    condicionAdicional: json['condicion_adicional']?.toString(),
    firmaClienteBase64: json['firma_cliente_base64']?.toString(),
    latCaptura: double.tryParse(json['lat_captura']?.toString() ?? ''),
    lngCaptura: double.tryParse(json['lng_captura']?.toString() ?? ''),
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'monto_solicitado': montoSolicitado,
    'cuotas': cuotas,
    'tasa_interes': tasaInteres,
    'motivo': motivo,
    'estado': estado,
    'numero_expediente': numeroExpediente,
    'canal': canal,
    'garantia': garantia,
    'seguro_desgravamen': seguroDesgravamen,
    if (montoAprobado != null) 'monto_aprobado': montoAprobado,
    if (motivoRechazo != null) 'motivo_rechazo': motivoRechazo,
    if (condicionAdicional != null) 'condicion_adicional': condicionAdicional,
    if (firmaClienteBase64 != null) 'firma_cliente_base64': firmaClienteBase64,
    if (latCaptura != null) 'lat_captura': latCaptura,
    if (lngCaptura != null) 'lng_captura': lngCaptura,
  };
}
