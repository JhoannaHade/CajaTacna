import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/tarjeta_models.dart';

class TarjetaRepository {
  final SupabaseClient _client;

  TarjetaRepository(this._client);

  Future<List<Tarjeta>> getTarjetas() async {
    final response = await _client.get('/rest/v1/tarjetas', query: {
      'select': '*',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Tarjeta.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar tarjetas: ${response.statusCode}');
    }
  }
}
