import 'dart:convert';
import '../core/network/supabase_client.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  /// Inicia sesión con email y contraseña.
  Future<AuthResponse> login(String email, String password) async {
    final response = await _client.post(
      '/auth/v1/token?grant_type=password',
      {'email': email, 'password': password},
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return AuthResponse.fromJson(body);
    } else {
      final msg = body['error_description'] ?? body['error'] ?? 'Error de acceso';
      throw Exception(_friendlyError(msg.toString()));
    }
  }

  /// Registra un usuario nuevo. Si el email ya existe intenta login directo.
  Future<AuthResponse> signUp(String email, String password) async {
    final response = await _client.post(
      '/auth/v1/signup',
      {
        'email': email,
        'password': password,
        // Confirmar email automáticamente (requiere "Disable email confirmations" en Supabase)
        'data': {'email_confirm': true},
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final authResp = AuthResponse.fromJson(body);
      // Si Supabase devuelve usuario pero sin token (confirmación pendiente),
      // intentamos login directo.
      if (authResp.accessToken.isEmpty && authResp.user != null) {
        return login(email, password);
      }
      if (authResp.accessToken.isEmpty && authResp.error == null) {
        // Usuario ya existía, intentar login
        return login(email, password);
      }
      return authResp;
    } else if (response.statusCode == 400) {
      // "User already registered" → intentar login
      final err = body['error'] ?? body['msg'] ?? '';
      if (err.toString().toLowerCase().contains('already')) {
        return login(email, password);
      }
      final msg = body['error_description'] ?? body['error'] ?? 'Error en el registro';
      throw Exception(_friendlyError(msg.toString()));
    } else {
      final msg = body['error_description'] ?? body['error'] ?? 'Error en el registro';
      throw Exception(_friendlyError(msg.toString()));
    }
  }

  /// Verifica que el token actual sigue siendo válido.
  Future<UserData?> getUser() async {
    final response = await _client.get('/auth/v1/user');
    if (response.statusCode == 200) {
      return UserData.fromJson(jsonDecode(response.body));
    }
    return null;
  }

  /// Cierra la sesión en Supabase.
  Future<void> logout() async {
    try {
      await _client.post('/auth/v1/logout', {});
    } catch (_) {}
  }

  String _friendlyError(String raw) {
    if (raw.contains('Invalid login credentials')) {
      return 'Correo o clave incorrectos. Verifica tus datos.';
    }
    if (raw.contains('Email not confirmed')) {
      return 'Confirma tu correo antes de ingresar.';
    }
    if (raw.contains('already registered')) {
      return 'Este correo ya está registrado.';
    }
    if (raw.contains('Password should be')) {
      return 'La clave debe tener al menos 6 dígitos.';
    }
    return raw;
  }
}
