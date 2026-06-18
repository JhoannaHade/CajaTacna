import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/prestamo_model.dart';
import '../models/accion_cobranza_model.dart';

class CobranzaRepository {
  final SupabaseClient _client;

  CobranzaRepository(this._client);

  /// Obtiene préstamos activos con saldo pendiente para realizar cobranza
  Future<List<Prestamo>> getPrestamosEnMora() async {
    final response = await _client.get('/rest/v1/prestamos', query: {
      'capital_pendiente': 'gt.0',
      'select': '*',
    });

    if (response.statusCode != 200) {
      throw Exception('Error al cargar préstamos en mora: ${response.statusCode} - ${response.body}');
    }

    final List prestamosData = jsonDecode(response.body);

    final perfilesResponse = await _client.get('/rest/v1/perfiles', query: {
      'select': '*',
    });

    final Map<String, dynamic> perfilesMap = {};
    if (perfilesResponse.statusCode == 200) {
      final List perfilesData = jsonDecode(perfilesResponse.body);
      for (var p in perfilesData) {
        if (p['user_id'] != null) {
          perfilesMap[p['user_id'].toString()] = p;
        }
      }
    }

    return prestamosData.map((e) {
      final clientUserId = e['user_id']?.toString() ?? '';
      final Map<String, dynamic> mapped = Map<String, dynamic>.from(e);
      if (perfilesMap.containsKey(clientUserId)) {
        mapped['perfiles'] = perfilesMap[clientUserId];
      }
      return Prestamo.fromJson(mapped);
    }).toList();
  }

  /// Registra una gestión de cobranza en la base de datos
  Future<bool> registrarAccion(AccionCobranza accion) async {
    final response = await _client.post(
      '/rest/v1/acciones_cobranza',
      accion.toJson(),
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }
}
