import 'package:flutter/foundation.dart';
import '../models/cartera_diaria_model.dart';
import '../repositories/cartera_repository.dart';

class CarteraProvider extends ChangeNotifier {
  final CarteraRepository _repository;

  CarteraProvider(this._repository);

  List<CarteraDiaria> _visitas = [];
  bool _isLoading = false;
  String? _error;

  List<CarteraDiaria> get visitas => _visitas;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendientesCount => _visitas.where((v) => v.estadoVisita == 'pendiente').length;
  int get visitadosCount => _visitas.where((v) => v.estadoVisita != 'pendiente').length;

  Future<void> cargarCartera(String advisorUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _visitas = await _repository.getCartera(advisorUserId);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarVisita({
    required String id,
    required String resultado,
    required String observacion,
    required String advisorUserId,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ok = await _repository.registrarVisita(id, resultado, observacion);
      if (ok) {
        await cargarCartera(advisorUserId);
        return true;
      } else {
        _error = 'No se pudo guardar el registro de la visita.';
        return false;
      }
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
