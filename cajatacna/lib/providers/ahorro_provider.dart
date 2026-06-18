import 'package:flutter/foundation.dart';
import '../models/ahorro_models.dart';
import '../repositories/ahorro_repository.dart';

class AhorroProvider extends ChangeNotifier {
  final AhorroRepository _repo;

  AhorroProvider(this._repo);

  List<CuentaAhorroCP> _cuentas = [];
  List<MovimientoAhorro> _movimientos = [];
  CuentaAhorroCP? _cuentaSeleccionada;
  bool _isLoading = false;
  String? _error;

  List<CuentaAhorroCP> get cuentas => _cuentas;
  List<MovimientoAhorro> get movimientos => _movimientos;
  CuentaAhorroCP? get cuentaSeleccionada => _cuentaSeleccionada;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarCuentasAhorro(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cuentas = await _repo.getCuentasAhorro(userId);
      if (_cuentas.isNotEmpty) {
        _cuentaSeleccionada = _cuentas[0];
        await cargarMovimientos(_cuentas[0].id);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarMovimientos(String cuentaId) async {
    try {
      _movimientos = await _repo.getMovimientos(cuentaId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void seleccionarCuenta(CuentaAhorroCP cuenta) async {
    _cuentaSeleccionada = cuenta;
    await cargarMovimientos(cuenta.id);
    notifyListeners();
  }

  Future<void> depositar(double monto) async {
    if (_cuentaSeleccionada == null) {
      _error = 'No hay cuenta seleccionada';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevoSaldo = _cuentaSeleccionada!.saldo + monto;
      await _repo.depositar(_cuentaSeleccionada!.id, monto, nuevoSaldo);
      _cuentaSeleccionada = CuentaAhorroCP(
        id: _cuentaSeleccionada!.id,
        userId: _cuentaSeleccionada!.userId,
        numeroCuenta: _cuentaSeleccionada!.numeroCuenta,
        saldo: nuevoSaldo,
        moneda: _cuentaSeleccionada!.moneda,
      );
      await cargarMovimientos(_cuentaSeleccionada!.id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
