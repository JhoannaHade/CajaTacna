import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/perfil_models.dart';

class PerfilRepository {
  final SupabaseClient _client;

  PerfilRepository(this._client);

  Future<Perfil?> getPerfil(String userId) async {
    final response = await _client.get('/rest/v1/perfiles', query: {
      'user_id': 'eq.$userId',
      'select': '*',
      'limit': '1',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return Perfil.fromJson(data[0]);
      }
      return null;
    } else {
      throw Exception('Error al cargar perfil: ${response.statusCode}');
    }
  }

  Future<void> actualizarPerfil(
    String userId,
    String telefono,
    String direccion,
  ) async {
    final response = await _client.patch(
      '/rest/v1/perfiles',
      {
        'telefono': telefono,
        'direccion': direccion,
      },
      query: {'user_id': 'eq.$userId'},
    );

    if (response.statusCode != 200) {
      throw Exception('Error al actualizar perfil: ${response.statusCode}');
    }
  }
}
