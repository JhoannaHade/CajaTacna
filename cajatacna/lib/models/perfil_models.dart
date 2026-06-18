class Perfil {
  final String id;
  final String userId;
  final String nombreCompleto;
  final String telefono;
  final String direccion;
  final String fechaRegistro;

  Perfil({
    required this.id,
    required this.userId,
    required this.nombreCompleto,
    required this.telefono,
    required this.direccion,
    required this.fechaRegistro,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) => Perfil(
    id: json['id']?.toString() ?? '',
    userId: json['user_id']?.toString() ?? '',
    nombreCompleto: json['nombre_completo'] ?? '',
    telefono: json['telefono'] ?? '',
    direccion: json['direccion'] ?? '',
    fechaRegistro: json['fecha_registro'] ?? '',
  );
}
