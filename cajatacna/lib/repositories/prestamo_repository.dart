import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/prestamo_models.dart';

class PrestamoRepository {
  final SupabaseClient _client;

  PrestamoRepository(this._client);

  Future<List<Prestamo>> getPrestamos() async {
    final response = await _client.get('/rest/v1/prestamos', query: {
      'select': '*',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Prestamo.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar préstamos: ${response.statusCode}');
    }
  }
}
