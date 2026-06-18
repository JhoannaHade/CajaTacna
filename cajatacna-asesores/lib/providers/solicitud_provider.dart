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

  // Estadísticas del Dashboard del Asesor
  int get solicitudesPendientesCount =>
      _solicitudes.where((s) => s.estado == 'pendiente').length;

  int get solicitudesAprobadasCount =>
      _solicitudes.where((s) => s.estado == 'aprobado').length;

  double get totalMontoAprobado => _solicitudes
      .where((s) => s.estado == 'aprobado')
      .fold(0.0, (sum, s) => sum + s.montoSolicitado);

  Future<void> cargarSolicitudes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _solicitudes = await _repository.getTodasLasSolicitudes();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Aprueba una solicitud de préstamo y efectúa el desembolso
  Future<bool> aprobarSolicitud({
    required SolicitudPrestamo solicitud,
    required double tasaInteres,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Obtener cuentas del cliente
      final cuentas = await _repository.getCuentasCliente(solicitud.userId);
      if (cuentas.isEmpty) {
        throw Exception('El cliente no tiene cuentas activas para el desembolso.');
      }

      // Buscar primera cuenta en soles, si no hay usar la primera disponible
      final cuentaDestino = cuentas.firstWhere(
        (c) => c['moneda']?.toString().toUpperCase() == 'PEN',
        orElse: () => cuentas.first,
      );

      final double saldoActual = double.tryParse(cuentaDestino['saldo']?.toString() ?? '') ?? 0.0;
      final double nuevoSaldo = saldoActual + solicitud.montoSolicitado;
      final String cuentaId = cuentaDestino['id']?.toString() ?? '';
      
      if (cuentaId.isEmpty) {
        throw Exception('ID de cuenta de cliente no válido.');
      }

      // 2. Transacción: Registrar la aprobación en solicitudes_prestamo
      final okEstado = await _repository.actualizarEstadoSolicitud(
        solicitud.id,
        'aprobado',
        tasaInteres,
      );
      if (!okEstado) throw Exception('No se pudo actualizar el estado de la solicitud.');

      // 3. Transacción: Insertar el préstamo en prestamos
      // Calcular cuotas estimadas
      final double capitalCuota = solicitud.montoSolicitado / solicitud.cuotas;
      final double interesCuota = (solicitud.montoSolicitado * (tasaInteres / 100)) / solicitud.cuotas;
      const double seguroCuota = 15.00;

      // Fecha límite: hoy + 30 días en formato YYYY-MM-DD
      final fechaLimite = DateTime.now().add(const Duration(days: 30));
      final String fechaLimiteStr = 
          "${fechaLimite.year}-${fechaLimite.month.toString().padLeft(2, '0')}-${fechaLimite.day.toString().padLeft(2, '0')}";

      final random4Digits = (1000 + (DateTime.now().millisecond % 9000)).toString();

      final okPrestamo = await _repository.crearPrestamo({
        'user_id': solicitud.userId,
        'tipo': 'Préstamo Aprobado Asesor',
        'numero_enmascarado': 'PP-****-$random4Digits',
        'capital_total': solicitud.montoSolicitado,
        'capital_pendiente': solicitud.montoSolicitado,
        'cuota_numero': 1,
        'cuotas_total': solicitud.cuotas,
        'fecha_limite': fechaLimiteStr,
        'capital_cuota': capitalCuota,
        'intereses_cuota': interesCuota,
        'seguros_cuota': seguroCuota,
      });

      if (!okPrestamo) throw Exception('No se pudo registrar el préstamo.');

      // 4. Transacción: Desembolsar saldo en la cuenta del cliente
      final okSaldo = await _repository.actualizarSaldoCuenta(cuentaId, nuevoSaldo);
      if (!okSaldo) throw Exception('No se pudo realizar el desembolso de saldo.');

      // 5. Transacción: Registrar movimiento de crédito en la cuenta
      await _repository.registrarTransaccion({
        'cuenta_id': cuentaId,
        'tipo': 'credito',
        'monto': solicitud.montoSolicitado,
        'descripcion': 'Desembolso Préstamo Asesor - Aprobado',
      });

      await cargarSolicitudes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rechaza una solicitud de préstamo
  Future<bool> rechazarSolicitud({required String id}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ok = await _repository.actualizarEstadoSolicitud(id, 'rechazado', 0.0);
      if (ok) {
        await cargarSolicitudes();
        return true;
      } else {
        _error = 'No se pudo rechazar la solicitud.';
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

  Future<bool> registrarDesembolso({
    required SolicitudPrestamo solicitud,
    required double montoAprobado,
    required double tasaInteres,
    required String firmaBase64,
    required double lat,
    required double lng,
    required List<Map<String, dynamic>> cuotasCronograma,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Obtener cuentas del cliente
      final cuentas = await _repository.getCuentasCliente(solicitud.userId);
      if (cuentas.isEmpty) {
        throw Exception('El cliente no tiene cuentas activas para el desembolso.');
      }

      // Buscar primera cuenta en soles
      final cuentaDestino = cuentas.firstWhere(
        (c) => c['moneda']?.toString().toUpperCase() == 'PEN',
        orElse: () => cuentas.first,
      );

      final double saldoActual = double.tryParse(cuentaDestino['saldo']?.toString() ?? '') ?? 0.0;
      final double nuevoSaldo = saldoActual + montoAprobado;
      final String cuentaId = cuentaDestino['id']?.toString() ?? '';
      
      if (cuentaId.isEmpty) {
        throw Exception('ID de cuenta de cliente no válido.');
      }

      // 2. Crear el Crédito (tabla creditos)
      final creditoRes = await _repository.crearCredito({
        'user_id': solicitud.userId,
        'monto': montoAprobado,
        'saldo_restante': montoAprobado,
        'cuotas': solicitud.cuotas,
        'cuotas_pagadas': 0,
        'tasa_interes': tasaInteres,
      });

      if (creditoRes == null || creditoRes['id'] == null) {
        throw Exception('No se pudo registrar el crédito en la tabla creditos.');
      }
      final String creditoId = creditoRes['id'].toString();

      // 3. Crear el Cronograma (tabla cronograma_pagos)
      final List<Map<String, dynamic>> cuotasRows = cuotasCronograma.map((c) => {
        'credito_id': creditoId,
        'fecha_vencimiento': c['fecha_vencimiento'],
        'monto_cuota': c['monto_cuota'],
        'estado': 'pendiente',
        'nro_cuota': c['nro_cuota'],
        'monto_capital': c['monto_capital'],
        'monto_interes': c['monto_interes'],
        'saldo': c['saldo'],
      }).toList();

      final okCronograma = await _repository.crearCronograma(cuotasRows);
      if (!okCronograma) throw Exception('No se pudo registrar el cronograma de pagos.');

      // 4. Crear el Préstamo (tabla prestamos)
      final random4Digits = (1000 + (DateTime.now().millisecond % 9000)).toString();
      final double capitalCuota = montoAprobado / solicitud.cuotas;
      final double interesCuota = (montoAprobado * (tasaInteres / 100)) / solicitud.cuotas;
      
      final okPrestamo = await _repository.crearPrestamo({
        'user_id': solicitud.userId,
        'tipo': 'Crédito Empresarial',
        'numero_enmascarado': 'PP-****-$random4Digits',
        'capital_total': montoAprobado,
        'capital_pendiente': montoAprobado,
        'cuota_numero': 1,
        'cuotas_total': solicitud.cuotas,
        'fecha_limite': cuotasCronograma.first['fecha_vencimiento'],
        'capital_cuota': capitalCuota,
        'intereses_cuota': interesCuota,
        'seguros_cuota': 0.0,
      });
      if (!okPrestamo) throw Exception('No se pudo registrar el préstamo en la tabla prestamos.');

      // 5. Actualizar la Solicitud
      final okSolicitud = await _repository.actualizarSolicitud(solicitud.id, {
        'estado': 'desembolsado',
        'tasa_interes': tasaInteres,
        'monto_aprobado': montoAprobado,
        'firma_cliente_base64': firmaBase64,
        'lat_captura': lat,
        'lng_captura': lng,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (!okSolicitud) throw Exception('No se pudo actualizar el estado de la solicitud.');

      // 6. Actualizar Saldo de Cuenta
      final okSaldo = await _repository.actualizarSaldoCuenta(cuentaId, nuevoSaldo);
      if (!okSaldo) throw Exception('No se pudo realizar el desembolso de saldo.');

      // 7. Registrar Transacción
      await _repository.registrarTransaccion({
        'cuenta_id': cuentaId,
        'tipo': 'credito',
        'monto': montoAprobado,
        'descripcion': 'Desembolso Préstamo ${solicitud.numeroExpediente ?? ''}',
      });

      await cargarSolicitudes();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rechazarSolicitudConMotivo({
    required String id,
    required String motivoRechazo,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ok = await _repository.actualizarSolicitud(id, {
        'estado': 'rechazado',
        'motivo_rechazo': motivoRechazo,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (ok) {
        await cargarSolicitudes();
        return true;
      } else {
        _error = 'No se pudo rechazar la solicitud.';
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

  Future<bool> actualizarEstadoSimple(String id, String estado) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final ok = await _repository.actualizarSolicitud(id, {
        'estado': estado,
        'updated_at': DateTime.now().toIso8601String(),
      });
      if (ok) {
        await cargarSolicitudes();
        return true;
      } else {
        _error = 'No se pudo actualizar el estado.';
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

  Future<bool> guardarDocLink(String solicitudId, String tipo, String storageUrl) async {
    try {
      return await _repository.guardarDocumento({
        'solicitud_id': solicitudId,
        'tipo_documento': tipo,
        'storage_url': storageUrl,
      });
    } catch (e) {
      return false;
    }
  }
}
