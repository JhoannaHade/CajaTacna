import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/ahorro_models.dart';

class AhorroRepository {
  final SupabaseClient _client;

  AhorroRepository(this._client);

  Future<List<CuentaAhorroCP>> getCuentasAhorro(String userId) async {
    final response = await _client.get('/rest/v1/cuentas_ahorro', query: {
      'user_id': 'eq.$userId',
      'select': '*',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CuentaAhorroCP.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar cuentas de ahorro: ${response.statusCode}');
    }
  }

  Future<List<MovimientoAhorro>> getMovimientos(String cuentaId) async {
    final response = await _client.get('/rest/v1/movimientos_ahorro', query: {
      'cuenta_id': 'eq.$cuentaId',
      'select': '*',
      'order': 'fecha.desc',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => MovimientoAhorro.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar movimientos: ${response.statusCode}');
    }
  }

  Future<void> depositar(String cuentaId, double monto, double nuevoSaldo) async {
    // Crear movimiento
    await _client.post('/rest/v1/movimientos_ahorro', {
      'cuenta_id': cuentaId,
      'tipo': 'deposito',
      'monto': monto,
      'descripcion': 'Depósito',
      'fecha': DateTime.now().toIso8601String(),
    });

    // Actualizar saldo
    await _client.patch(
      '/rest/v1/cuentas_ahorro',
      {'saldo': nuevoSaldo},
      query: {'id': 'eq.$cuentaId'},
    );
  }
}
