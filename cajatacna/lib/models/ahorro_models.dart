class CuentaAhorroCP {
  final String id;
  final String userId;
  final String numeroCuenta;
  final double saldo;
  final String moneda;

  CuentaAhorroCP({
    required this.id,
    required this.userId,
    required this.numeroCuenta,
    required this.saldo,
    required this.moneda,
  });

  factory CuentaAhorroCP.fromJson(Map<String, dynamic> json) =>
      CuentaAhorroCP(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        numeroCuenta: json['numero_cuenta'] ?? '',
        saldo: (json['saldo'] ?? 0.0).toDouble(),
        moneda: json['moneda'] ?? 'PEN',
      );
}

class MovimientoAhorro {
  final String id;
  final String cuentaId;
  final String tipo;
  final double monto;
  final String descripcion;
  final String fecha;

  MovimientoAhorro({
    required this.id,
    required this.cuentaId,
    required this.tipo,
    required this.monto,
    required this.descripcion,
    required this.fecha,
  });

  factory MovimientoAhorro.fromJson(Map<String, dynamic> json) =>
      MovimientoAhorro(
        id: json['id']?.toString() ?? '',
        cuentaId: json['cuenta_id']?.toString() ?? '',
        tipo: json['tipo'] ?? '',
        monto: (json['monto'] ?? 0.0).toDouble(),
        descripcion: json['descripcion'] ?? '',
        fecha: json['fecha'] ?? '',
      );
}
