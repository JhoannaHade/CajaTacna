import 'package:flutter/foundation.dart';
import '../models/prestamo_model.dart';
import '../models/accion_cobranza_model.dart';
import '../repositories/cobranza_repository.dart';

class CobranzaProvider extends ChangeNotifier {
  final CobranzaRepository _repository;

  CobranzaProvider(this._repository);

  List<Prestamo> _prestamosEnMora = [];
  bool _isLoading = false;
  String? _error;

  List<Prestamo> get prestamosEnMora => _prestamosEnMora;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarPrestamosEnMora() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _prestamosEnMora = await _repository.getPrestamosEnMora();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registrarGestion({
    required String advisorUserId,
    required String clientUserId,
    required String tipoGestion,
    required String resultado,
    required double montoPagado,
    String? fechaCompromiso,
    required double montoCompromiso,
    required String observaciones,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaAccion = AccionCobranza(
        id: '',
        asesorId: advisorUserId,
        clienteId: clientUserId,
        tipoGestion: tipoGestion,
        resultado: resultado,
        montoPagado: montoPagado,
        fechaCompromiso: fechaCompromiso,
        montoCompromiso: montoCompromiso,
        observaciones: observaciones,
        timestampGestion: DateTime.now(),
      );

      final ok = await _repository.registrarAccion(nuevaAccion);
      if (ok) {
        await cargarPrestamosEnMora();
        return true;
      } else {
        _error = 'No se pudo registrar la acción de cobranza.';
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
