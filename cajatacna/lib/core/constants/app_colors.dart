import 'package:flutter/material.dart';

class AppColors {
  // Colores corporativos Caja Tacna
  static const Color azulPrincipal = Color(0xFFD21E20); // Rojo corporativo Caja Tacna
  static const Color azulSecundario = Color(0xFFA51417); // Rojo oscuro Caja Tacna para gradientes
  static const Color naranjaBCP = Color(0xFFE5A93B); // Dorado/Ámbar Caja Tacna
  static const Color fondoGrisClaro = Color(0xFFF5F7FA);
  static const Color grisTexto = Color(0xFF4A4A4A);
  static const Color azulOscuro = Color(0xFF800C0E); // Rojo muy oscuro para contraste
  static const Color azulMarino = Color(0xFF4D0001); // Bordó oscuro
  static const Color azulClaro = Color(0xFFFDE8E8); // Rojo muy claro / rosa suave para alertas
  static const Color naranjaOscuro = Color(0xFFC78D24); // Dorado oscuro para contraste
  static const Color verdeExito = Color(0xFF2ECC71);
  static const Color rojoError = Color(0xFFE74C3C);
  static const Color naranjaAviso = Color(0xFFF39C12);
  static const Color blancoCard = Colors.white;
  static const Color textoSecundario = Color(0xFF757575);

  // Deprecated colors from Caja Piura (mapped to Caja Tacna colors for backward compatibility)
  @Deprecated('Use naranjaBCP instead')
  static const Color doradoCP = naranjaBCP;
  @Deprecated('Use naranjaOscuro instead')
  static const Color doradoOscuro = naranjaOscuro;
}
