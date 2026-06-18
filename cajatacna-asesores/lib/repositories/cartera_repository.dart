import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/cartera_diaria_model.dart';

class CarteraRepository {
  final SupabaseClient _client;

  CarteraRepository(this._client);

  Future<List<CarteraDiaria>> getCartera(String advisorUserId) async {
    final carteraResponse = await _client.get('/rest/v1/cartera_diaria', query: {
      'asesor_id': 'eq.$advisorUserId',
      'select': '*',
    });

    if (carteraResponse.statusCode != 200) {
      throw Exception('Error al cargar la cartera diaria: ${carteraResponse.statusCode} - ${carteraResponse.body}');
    }

    final List carteraData = jsonDecode(carteraResponse.body);

    final perfilesResponse = await _client.get('/rest/v1/perfiles', query: {
      'es_asesor': 'eq.false',
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

    return carteraData.map((c) {
      final clientUserId = c['cliente_id']?.toString() ?? '';
      final Map<String, dynamic> mapped = Map<String, dynamic>.from(c);
      if (perfilesMap.containsKey(clientUserId)) {
        mapped['perfiles'] = perfilesMap[clientUserId];
      }
      return CarteraDiaria.fromJson(mapped);
    }).toList();
  }

  Future<bool> registrarVisita(String id, String resultado, String observacion) async {
    final response = await _client.patch(
      '/rest/v1/cartera_diaria',
      {
        'estado_visita': 'visitado',
        'resultado_visita': resultado,
        'observacion_visita': observacion,
        'timestamp_visita': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      query: {
        'id': 'eq.$id',
      },
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
