import 'package:flutter/foundation.dart';
import '../models/solicitud_prestamo_model.dart';
import '../repositories/solicitud_repository.dart';

class SolicitudProvider extends ChangeNotifier {
  final SolicitudRepository _repository;

  SolicitudProvider(this._repository);

  List<SolicitudPrestamo> _solicitudes = [];
  bool _isLoading = false;
  String? _error;

  List<SolicitudPrestamo> get solicitudes => _solicitudes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> cargarSolicitudes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _solicitudes = await _repository.getSolicitudes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearSolicitud({
    required String userId,
    required double monto,
    required int cuotas,
    required String motivo,
    required String garantia,
    required bool seguroDesgravamen,
    required double tasaInteres,
    required String numeroExpediente,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final nuevaSolicitud = SolicitudPrestamo(
        id: '',
        userId: userId,
        montoSolicitado: monto,
        cuotas: cuotas,
        tasaInteres: tasaInteres,
        motivo: motivo,
        estado: 'enviado',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        numeroExpediente: numeroExpediente,
        canal: 'cliente',
        garantia: garantia,
        seguroDesgravamen: seguroDesgravamen,
      );

      final success = await _repository.crearSolicitud(nuevaSolicitud);
      if (success) {
        await cargarSolicitudes();
        return true;
      } else {
        _error = 'No se pudo crear la solicitud. Intenta de nuevo.';
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
