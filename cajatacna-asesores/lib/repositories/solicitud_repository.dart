import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/solicitud_prestamo_model.dart';

class SolicitudRepository {
  final SupabaseClient _client;

  SolicitudRepository(this._client);

  Future<List<SolicitudPrestamo>> getTodasLasSolicitudes() async {
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

  Future<Map<String, dynamic>> getPerfilCliente(String clientUserId) async {
    final response = await _client.get('/rest/v1/perfiles', query: {
      'user_id': 'eq.$clientUserId',
      'select': '*',
    });
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return data.first;
      }
    }
    return {};
  }

  Future<List<Map<String, dynamic>>> getCuentasCliente(String clientUserId) async {
    final response = await _client.get('/rest/v1/cuentas', query: {
      'user_id': 'eq.$clientUserId',
      'select': '*',
    });
    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  Future<bool> actualizarEstadoSolicitud(String id, String estado, double tasa) async {
    final response = await _client.patch(
      '/rest/v1/solicitudes_prestamo',
      {
        'estado': estado,
        'tasa_interes': tasa,
        'updated_at': DateTime.now().toIso8601String(),
      },
      query: {
        'id': 'eq.$id',
      },
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> crearPrestamo(Map<String, dynamic> prestamoData) async {
    final response = await _client.post(
      '/rest/v1/prestamos',
      prestamoData,
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> actualizarSaldoCuenta(String cuentaId, double nuevoSaldo) async {
    final response = await _client.patch(
      '/rest/v1/cuentas',
      {
        'saldo': nuevoSaldo,
      },
      query: {
        'id': 'eq.$cuentaId',
      },
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> registrarTransaccion(Map<String, dynamic> txData) async {
    final response = await _client.post(
      '/rest/v1/transacciones',
      txData,
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> actualizarSolicitud(String id, Map<String, dynamic> body) async {
    final response = await _client.patch(
      '/rest/v1/solicitudes_prestamo',
      body,
      query: {
        'id': 'eq.$id',
      },
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<Map<String, dynamic>?> crearCredito(Map<String, dynamic> body) async {
    final response = await _client.post(
      '/rest/v1/creditos',
      body,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return Map<String, dynamic>.from(data.first);
      }
    }
    return null;
  }

  Future<bool> crearCronograma(List<Map<String, dynamic>> cuotas) async {
    final response = await _client.post(
      '/rest/v1/cronograma_pagos',
      cuotas,
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }

  Future<bool> guardarDocumento(Map<String, dynamic> docData) async {
    final response = await _client.post(
      '/rest/v1/solicitudes_documentos',
      docData,
    );
    return response.statusCode == 201 || response.statusCode == 200;
  }
}
