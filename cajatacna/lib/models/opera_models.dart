class TransferenciaInsert {
  final String cuentaDestino;
  final double monto;
  final String descripcion;

  TransferenciaInsert({
    required this.cuentaDestino,
    required this.monto,
    required this.descripcion,
  });

  Map<String, dynamic> toJson() => {
    'cuenta_destino': cuentaDestino,
    'monto': monto,
    'descripcion': descripcion,
    'fecha': DateTime.now().toIso8601String(),
  };
}

class PagoServicioInsert {
  final String servicio;
  final String contrato;
  final double monto;

  PagoServicioInsert({
    required this.servicio,
    required this.contrato,
    required this.monto,
  });

  Map<String, dynamic> toJson() => {
    'servicio': servicio,
    'contrato': contrato,
    'monto': monto,
    'estado': 'procesado',
    'fecha': DateTime.now().toIso8601String(),
  };
}

class Pago {
  final String id;
  final String servicio;
  final double monto;
  final String fecha;
  final String estado;

  Pago({
    required this.id,
    required this.servicio,
    required this.monto,
    required this.fecha,
    required this.estado,
  });

  factory Pago.fromJson(Map<String, dynamic> json) => Pago(
    id: json['id']?.toString() ?? '',
    servicio: json['servicio'] ?? '',
    monto: (json['monto'] ?? 0.0).toDouble(),
    fecha: json['fecha'] ?? '',
    estado: json['estado'] ?? '',
  );
}
