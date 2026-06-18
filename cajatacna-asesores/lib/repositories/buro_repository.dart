import 'dart:convert';
import 'dart:math';
import '../core/network/supabase_client.dart';
import '../models/consulta_buro_model.dart';

class BuroRepository {
  final SupabaseClient _client;

  BuroRepository(this._client);

  /// Obtiene los perfiles de los clientes disponibles para consulta
  Future<List<Map<String, dynamic>>> getClientes() async {
    final response = await _client.get('/rest/v1/perfiles', query: {
      'es_asesor': 'eq.false',
      'select': '*',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  /// Busca una consulta de buró previa por DNI
  Future<ConsultaBuro?> getConsultaBuro(String dni) async {
    final response = await _client.get('/rest/v1/consultas_buro', query: {
      'dni_consultado': 'eq.$dni',
      'select': '*',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        return ConsultaBuro.fromJson(data.first);
      }
    }
    return null;
  }

  /// Registra una nueva consulta de buró simulando el scoring
  Future<ConsultaBuro> preEvaluarYConsultar({
    required String advisorUserId,
    required String clientUserId,
    required String dni,
  }) async {
    // Verificar si ya existe
    final existente = await getConsultaBuro(dni);
    if (existente != null) {
      return existente;
    }

    // Si no existe, simular y guardar
    final score = 520 + Random().nextInt(320); // 520 a 840
    String riesgo = 'Bajo';
    if (score < 600) riesgo = 'Alto';
    else if (score < 720) riesgo = 'Medio';

    final body = {
      'asesor_id': advisorUserId,
      'cliente_id': clientUserId,
      'dni_consultado': dni,
      'calificacion_sbs': score > 700 ? 'Normal' : 'CPP',
      'entidades_con_deuda': score > 700 ? 1 : 3,
      'deuda_total_pen': score > 700 ? 1200.00 : 8500.00,
      'mayor_deuda': score > 700 ? 1000.00 : 5000.00,
      'dias_mayor_mora': score > 700 ? 0 : 25,
      'en_lista_negra': score < 580,
      'motivo_bloqueo': score < 580 ? 'Cliente reportado con deudas en cobranza coactiva' : null,
      'score_sentinel': score,
      'riesgo': riesgo,
    };

    final response = await _client.post('/rest/v1/consultas_buro', body);
    if (response.statusCode == 201 || response.statusCode == 200) {
      // Supabase devuelve el objeto insertado, o usamos el body directamente
      try {
        final List data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          return ConsultaBuro.fromJson(data.first);
        }
      } catch (_) {}
      return ConsultaBuro.fromJson(body);
    } else {
      throw Exception('Error al guardar consulta de buró: ${response.statusCode}');
    }
  }
}
