import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/cuenta_models.dart';

class CuentaRepository {
  final SupabaseClient _client;

  CuentaRepository(this._client);

  Future<List<Cuenta>> getCuentas() async {
    final response = await _client.get('/rest/v1/cuentas', query: {
      'select': '*',
      'order': 'tipo.asc',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Cuenta.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar cuentas: ${response.statusCode}');
    }
  }

  Future<List<Transaccion>> getTransacciones(String cuentaId) async {
    final response = await _client.get('/rest/v1/transacciones', query: {
      'cuenta_id': 'eq.$cuentaId',
      'select': '*',
      'order': 'fecha.desc',
      'limit': '10',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Transaccion.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar transacciones: ${response.statusCode}');
    }
  }
}
