import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/solicitud_prestamo_model.dart';

class SolicitudRepository {
  final SupabaseClient _client;

  SolicitudRepository(this._client);

  Future<List<SolicitudPrestamo>> getSolicitudes() async {
    final response = await _client.get('/rest/v1/solicitudes_prestamo', query: {
      'select': '*',
      'order': 'created_at.desc',
    });

    if (response.statusCode != 200) {
      throw Exception('Error al cargar solicitudes: ${response.statusCode} - ${response.body}');
    }

    final List solicitudesData = jsonDecode(response.body);

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

    return solicitudesData.map((e) {
      final clientUserId = e['user_id']?.toString() ?? '';
      final Map<String, dynamic> mapped = Map<String, dynamic>.from(e);
      if (perfilesMap.containsKey(clientUserId)) {
        mapped['perfiles'] = perfilesMap[clientUserId];
      }
      return SolicitudPrestamo.fromJson(mapped);
    }).toList();
  }

  Future<bool> crearSolicitud(SolicitudPrestamo solicitud) async {
    final response = await _client.post(
      '/rest/v1/solicitudes_prestamo',
      solicitud.toJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al crear la solicitud: ${response.statusCode} - ${response.body}');
    }
  }
}
