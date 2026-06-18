class Cuenta {
  final String id;
  final String userId;
  final String tipo;
  final String numeroCuenta;
  final double saldo;

  Cuenta({
    required this.id,
    required this.userId,
    required this.tipo,
    required this.numeroCuenta,
    required this.saldo,
  });

  factory Cuenta.fromJson(Map<String, dynamic> json) => Cuenta(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    tipo: json['tipo'] ?? '',
    numeroCuenta: json['numero_cuenta'] ?? '',
    saldo: (json['saldo'] ?? 0.0).toDouble(),
  );
}

class Transaccion {
  final String id;
  final String cuentaId;
  final String tipo;
  final double monto;
  final String descripcion;
  final String fecha;

  Transaccion({
    required this.id,
    required this.cuentaId,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  bool get esDebito => tipo == 'debito';

  String get montoFormateado => 'S/ ${monto.toStringAsFixed(2)}';

  factory Transaccion.fromJson(Map<String, dynamic> json) => Transaccion(
    id: json['id']?.toString() ?? '',
    cuentaId: json['cuenta_id']?.toString() ?? '',
    tipo: json['tipo'] ?? '',
    monto: (json['monto'] ?? 0.0).toDouble(),
    descripcion: json['descripcion'] ?? '',
    fecha: json['fecha'] ?? '',
  );
}

class CuentaAhorro {
  final String id;
  final String userId;
  final double saldo;
  final double metaAhorro;
  final double tasaInteres;
  final String fechaApertura;

  CuentaAhorro({
    required this.id,
    required this.userId,
    required this.saldo,
    required this.metaAhorro,
    required this.tasaInteres,
    required this.fechaApertura,
  });

  double get porcentaje {
    if (metaAhorro == 0) return 0;
    final p = (saldo / metaAhorro).toDouble();
    return p.clamp(0.0, 1.0);
  }

  factory CuentaAhorro.fromJson(Map<String, dynamic> json) => CuentaAhorro(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    saldo: (json['saldo'] ?? 0.0).toDouble(),
    metaAhorro: (json['meta_ahorro'] ?? 0.0).toDouble(),
    tasaInteres: (json['tasa_interes'] ?? 0.0).toDouble(),
    fechaApertura: json['fecha_apertura'] ?? '',
  );
}
