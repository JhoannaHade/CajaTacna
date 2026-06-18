import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_strings.dart';

class SupabaseClient {
  static final SupabaseClient _instance = SupabaseClient._internal();

  factory SupabaseClient() => _instance;

  SupabaseClient._internal();

  String? _token;
  final String _baseUrl = AppStrings.supabaseUrl;

  void setToken(String token) => _token = token;

  void clearToken() => _token = null;

  bool get isAuthenticated => _token != null;

  Map<String, String> get _baseHeaders => {
    'Content-Type': 'application/json',
    'apikey': AppStrings.supabaseAnonKey,
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Map<String, String> get _dbHeaders => {
    ..._baseHeaders,
    'Prefer': 'return=representation',
  };

  Future<http.Response> get(String path, {Map<String, String>? query}) {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    return http.get(uri, headers: _baseHeaders);
  }

  Future<http.Response> post(String path, dynamic body) {
    final uri = Uri.parse('$_baseUrl$path');
    return http.post(uri, headers: _dbHeaders, body: jsonEncode(body));
  }

  Future<http.Response> patch(String path, dynamic body,
      {Map<String, String>? query}) {
    final uri = Uri.parse('$_baseUrl$path').replace(queryParameters: query);
    return http.patch(uri, headers: _dbHeaders, body: jsonEncode(body));
  }
}
