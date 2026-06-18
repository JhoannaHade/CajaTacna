import 'package:flutter/foundation.dart';
import '../models/cuenta_models.dart';
import '../repositories/cuenta_repository.dart';

class CuentaProvider extends ChangeNotifier {
  final CuentaRepository _repo;

  CuentaProvider(this._repo);

  List<Cuenta> _cuentas = [];
  List<Transaccion> _transacciones = [];
  bool _isLoading = false;
  String? _error;

  List<Cuenta> get cuentas => _cuentas;
  List<Transaccion> get transacciones => _transacciones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarCuentas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cuentas = await _repo.getCuentas();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarTransacciones(String cuentaId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transacciones = await _repo.getTransacciones(cuentaId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
