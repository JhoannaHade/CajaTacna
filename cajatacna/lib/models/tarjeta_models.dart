class Tarjeta {
  final String id;
  final String userId;
  final String numero;
  final String tipo;
  final String marca;
  final String fechaVencimiento;

  Tarjeta({
    required this.id,
    required this.userId,
    required this.numero,
    required this.tipo,
    required this.marca,
    required this.fechaVencimiento,
  });

  factory Tarjeta.fromJson(Map<String, dynamic> json) => Tarjeta(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    numero: json['numero'] ?? '',
    tipo: json['tipo'] ?? '',
    marca: json['marca'] ?? '',
    fechaVencimiento: json['fecha_vencimiento'] ?? '',
  );
}
