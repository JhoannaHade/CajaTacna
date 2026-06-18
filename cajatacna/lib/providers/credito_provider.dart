import 'package:flutter/foundation.dart';
import '../models/credito_models.dart';
import '../repositories/credito_repository.dart';

class CreditoProvider extends ChangeNotifier {
  final CreditoRepository _repo;

  CreditoProvider(this._repo);

  List<Credito> _creditos = [];
  List<CronogramaPago> _cronograma = [];
  Credito? _creditoSeleccionado;
  bool _isLoading = false;
  String? _error;

  List<Credito> get creditos => _creditos;
  List<CronogramaPago> get cronograma => _cronograma;
  Credito? get creditoSeleccionado => _creditoSeleccionado;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarCreditos(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _creditos = await _repo.getCreditos(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarCronograma(String creditoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cronograma = await _repo.getCronograma(creditoId);
      _creditoSeleccionado =
          _creditos.firstWhere((c) => c.id == creditoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
