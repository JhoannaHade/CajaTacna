import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/credito_models.dart';

class CreditoRepository {
  final SupabaseClient _client;

  CreditoRepository(this._client);

  Future<List<Credito>> getCreditos(String userId) async {
    final response = await _client.get('/rest/v1/creditos', query: {
      'user_id': 'eq.$userId',
      'select': '*',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => Credito.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar créditos: ${response.statusCode}');
    }
  }

  Future<List<CronogramaPago>> getCronograma(String creditoId) async {
    final response = await _client.get('/rest/v1/cronograma_pagos', query: {
      'credito_id': 'eq.$creditoId',
      'select': '*',
      'order': 'fecha_vencimiento.asc',
    });

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => CronogramaPago.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar cronograma: ${response.statusCode}');
    }
  }
}
