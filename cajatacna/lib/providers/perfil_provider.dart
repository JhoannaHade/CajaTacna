import 'package:flutter/foundation.dart';
import '../models/perfil_models.dart';
import '../repositories/perfil_repository.dart';

class PerfilProvider extends ChangeNotifier {
  final PerfilRepository _repo;

  PerfilProvider(this._repo);

  Perfil? _perfil;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;

  Perfil? get perfil => _perfil;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> cargarPerfil(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _perfil = await _repo.getPerfil(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarPerfil(String telefono, String direccion) async {
    if (_perfil == null) {
      _error = 'Perfil no cargado';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _repo.actualizarPerfil(_perfil!.userId, telefono, direccion);
      _perfil = Perfil(
        id: _perfil!.id,
        userId: _perfil!.userId,
        nombreCompleto: _perfil!.nombreCompleto,
        telefono: telefono,
        direccion: direccion,
        fechaRegistro: _perfil!.fechaRegistro,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
