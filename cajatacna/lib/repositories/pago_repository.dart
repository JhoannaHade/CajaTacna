import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/opera_models.dart';

class PagoRepository {
  final SupabaseClient _client;

  PagoRepository(this._client);

  Future<List<Pago>> getPagos() async {
    final response = await _client.get('/rest/v1/pagos', query: {
      'select': '*',
      'order': 'fecha.desc',
      'limit': '20',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Pago.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar pagos: ${response.statusCode}');
    }
  }
}
