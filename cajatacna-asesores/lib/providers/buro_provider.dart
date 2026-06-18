import 'package:flutter/foundation.dart';
import '../models/consulta_buro_model.dart';
import '../repositories/buro_repository.dart';

class BuroProvider extends ChangeNotifier {
  final BuroRepository _repository;

  BuroProvider(this._repository);

  List<Map<String, dynamic>> _clientes = [];
  ConsultaBuro? _consultaActual;
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get clientes => _clientes;
  ConsultaBuro? get consultaActual => _consultaActual;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarClientes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _clientes = await _repository.getClientes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> consultarBuro({
    required String advisorUserId,
    required String clientUserId,
    required String dni,
  }) async {
    _isLoading = true;
    _error = null;
    _consultaActual = null;
    notifyListeners();

    try {
      _consultaActual = await _repository.preEvaluarYConsultar(
        advisorUserId: advisorUserId,
        clientUserId: clientUserId,
        dni: dni,
      );
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void limpiarConsulta() {
    _consultaActual = null;
    _error = null;
    notifyListeners();
  }
}
