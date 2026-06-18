import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_strings.dart';
import '../core/network/supabase_client.dart';
import '../models/auth_models.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo;
  final SupabaseClient _client;

  AuthProvider(this._authRepo, this._client);

  bool _isLoading = false;
  String? _error;
  UserData? _currentUser;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  UserData? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Login con email + clave de 6 dígitos.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepo.login(email, password);
      _client.setToken(response.accessToken);
      _currentUser = response.user;
      _isAuthenticated = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppStrings.prefToken, response.accessToken);
      if (response.refreshToken != null) {
        await prefs.setString(AppStrings.prefRefreshToken, response.refreshToken!);
      }
      if (response.user != null) {
        await prefs.setString(AppStrings.prefUserId, response.user!.id);
        await prefs.setString(AppStrings.prefUserEmail, response.user!.email);
      }

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registro completo: crea usuario en Auth + perfil en DB + tarjeta débito.
  Future<bool> registerAccount({
    required String nombre,
    required String email,
    required String password,
    required String numeroTarjeta,
    required String tipoDocumento,
    required String numeroDocumento,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authRepo.signUp(email, password);

      if (response.accessToken.isEmpty) {
        throw Exception('No se pudo completar el registro. Verifica tus datos.');
      }

      _client.setToken(response.accessToken);
      _currentUser = response.user;
      _isAuthenticated = true;

      final userId = response.user?.id ?? '';
      if (userId.isEmpty) {
        throw Exception('No se recibió el ID de usuario de Supabase.');
      }

      final last4 = numeroTarjeta.replaceAll(' ', '').substring(
            numeroTarjeta.replaceAll(' ', '').length - 4,
          );

      // Insertar perfil (el trigger on_perfil_created pobla cuentas automáticamente)
      final perfilRes = await _client.post('/rest/v1/perfiles', {
        'user_id': userId,
        'nombre_completo': nombre,
        'email': email,
        'tipo_documento': tipoDocumento,
        'numero_documento': numeroDocumento,
        'tarjeta_ultimos4': last4,
      });

      if (perfilRes.statusCode != 200 && perfilRes.statusCode != 201) {
        throw Exception('Error al crear el perfil. Intenta de nuevo.');
      }

      // Insertar tarjeta débito principal
      await _client.post('/rest/v1/tarjetas', {
        'user_id': userId,
        'numero': '**** **** **** $last4',
        'tipo': 'Debito',
        'marca': 'Visa',
        'fecha_vencimiento': '12/29',
      });

      // Guardar sesión localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppStrings.prefToken, response.accessToken);
      if (response.refreshToken != null) {
        await prefs.setString(AppStrings.prefRefreshToken, response.refreshToken!);
      }
      await prefs.setString(AppStrings.prefUserId, userId);
      await prefs.setString(AppStrings.prefUserEmail, email);
      await prefs.setString(AppStrings.prefUserName, nombre);
      await prefs.setBool(AppStrings.prefCardRegistered, true);
      await prefs.setString(AppStrings.prefCardLast4, last4);
      await prefs.setString(AppStrings.prefDocumentType, tipoDocumento);
      await prefs.setString(AppStrings.prefDocumentNumber, numeroDocumento);

      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Restaura la sesión guardada y valida el token con Supabase.
  /// Retorna true si la sesión es válida, false si expiró.
  Future<bool> tryRestoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppStrings.prefToken);
    final userId = prefs.getString(AppStrings.prefUserId);
    final email = prefs.getString(AppStrings.prefUserEmail);

    if (token == null || userId == null || email == null) return false;

    // Setear token temporalmente para validar
    _client.setToken(token);

    try {
      final user = await _authRepo.getUser();
      if (user != null) {
        _currentUser = user;
        _isAuthenticated = true;
        notifyListeners();
        return true;
      } else {
        // Token inválido → limpiar
        await _clearLocalSession(prefs);
        return false;
      }
    } catch (_) {
      await _clearLocalSession(prefs);
      return false;
    }
  }

  /// Cierra la sesión tanto en Supabase como localmente.
  Future<void> logout() async {
    try {
      await _authRepo.logout();
    } catch (_) {}

    _client.clearToken();
    _currentUser = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await _clearLocalSession(prefs);
    notifyListeners();
  }

  Future<void> _clearLocalSession(SharedPreferences prefs) async {
    await prefs.remove(AppStrings.prefToken);
    await prefs.remove(AppStrings.prefRefreshToken);
    await prefs.remove(AppStrings.prefUserId);
    await prefs.remove(AppStrings.prefUserEmail);
    _client.clearToken();
  }
}
