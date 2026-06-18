import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../models/cuenta_models.dart';
import '../providers/cuenta_provider.dart';
import '../widgets/app_scaffold.dart';

class CuentaScreen extends StatefulWidget {
  const CuentaScreen({super.key});

  @override
  State<CuentaScreen> createState() => _CuentaScreenState();
}

class _CuentaScreenState extends State<CuentaScreen> {
  Cuenta? _selectedCuenta;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    final provider = context.read<CuentaProvider>();
    
    if (args is Cuenta) {
      _selectedCuenta = args;
    } else if (provider.cuentas.isNotEmpty) {
      _selectedCuenta = provider.cuentas.first;
    }

    if (_selectedCuenta != null) {
      provider.cargarTransacciones(_selectedCuenta!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CuentaProvider>();
    final cuenta = _selectedCuenta;

    return AppScaffold(
      title: 'Cuentas',
      currentIndex: 0,
      showBottomNav: false, // Ocultar bottom nav en pantallas de detalle
      showAppBar: false,
      body: cuenta == null
          ? const Center(child: Text('No hay cuentas activas.'))
          : Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildAccountCard(cuenta),
                        _buildQuickActions(context),
                        const Divider(height: 1, color: Color(0xFFF2F4F7)),
                        _buildMovimientosHeader(),
                        _buildMovimientosList(provider),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.azulPrincipal,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(right: 40), // Offset back arrow width for centering
                child: Text(
                  'Cuentas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(Cuenta cuenta) {
    final isDolar = cuenta.tipo.toLowerCase().contains('dolar') ||
        cuenta.tipo.toLowerCase().contains('dollar') ||
        cuenta.tipo.toLowerCase().contains('usd');
    final formattedNum = cuenta.numeroCuenta;
    // Generate Peruvian CCI (20 digits: 002 + 355 + account_number + 65)
    final cci = '002355${formattedNum.padRight(12, '0').substring(0, 12)}65';

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cuenta.tipo.toUpperCase().replaceAll('CUENTA ', 'CLASICA '),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulPrincipal,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedNum,
                    style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'CCI: $cci',
                    style: const TextStyle(color: Color(0xFF667085), fontSize: 13),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.naranjaBCP, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined, color: AppColors.naranjaBCP, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Disponible',
            style: TextStyle(color: Color(0xFF667085), fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${isDolar ? 'US\$' : 'S/'} ${cuenta.saldo.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.azulPrincipal,
              fontSize: 36,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.swap_horiz, 'Transferir\ndinero', AppRoutes.transferencias),
      (Icons.water_drop_outlined, 'Pagar\nservicios', AppRoutes.pagos),
      (Icons.savings_outlined, 'Ahorra con\nWardaditos', AppRoutes.ahorro),
      (Icons.more_horiz, 'Más\n', ''),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((item) {
          return InkWell(
            onTap: () {
              if (item.$3.isNotEmpty) {
                Navigator.pushNamed(context, item.$3);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Más opciones próximamente')),
                );
              }
            },
            child: SizedBox(
              width: 80,
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.naranjaBCP,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(item.$1, color: Colors.white, size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.$2,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.azulPrincipal,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMovimientosHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Movimientos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.azulPrincipal,
            ),
          ),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Ver más',
              style: TextStyle(
                color: AppColors.naranjaBCP,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovimientosList(CuentaProvider provider) {
    if (provider.isLoading) {
      return Container(
        color: Colors.white,
        padding: const EdgeInsets.all(40),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.transacciones.isEmpty) {
      return Container(
        color: Colors.white,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        child: const Center(
          child: Text(
            'Sin movimientos recientes en esta cuenta.',
            style: TextStyle(color: AppColors.grisTexto, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Hoy',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF667085),
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.transacciones.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF2F4F7), indent: 72, endIndent: 20),
            itemBuilder: (context, index) {
              final t = provider.transacciones[index];
              return _MovimientoTile(transaccion: t);
            },
          ),
        ],
      ),
    );
  }
}

class _MovimientoTile extends StatelessWidget {
  final Transaccion transaccion;
  const _MovimientoTile({required this.transaccion});

  @override
  Widget build(BuildContext context) {
    final isDebito = transaccion.esDebito;
    
    // Nice date format: e.g. "18 Mayo"
    String fecha = transaccion.fecha;
    try {
      final dt = DateTime.parse(transaccion.fecha);
      final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
      fecha = '${dt.day} ${months[dt.month - 1]}';
    } catch (_) {}

    // Extract first letter of description for avatar
    final initial = transaccion.descripcion.isNotEmpty 
        ? transaccion.descripcion.substring(0, 1).toUpperCase() 
        : 'Y';

    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // Blue avatar with initial
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color(0xFFE6F0FA),
              child: Text(
                initial,
                style: const TextStyle(
                  color: AppColors.azulPrincipal,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaccion.descripcion,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.azulPrincipal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    fecha,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF667085),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(
                  '${isDebito ? '-' : ''}S/ ${transaccion.monto.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDebito ? AppColors.rojoError : AppColors.azulPrincipal,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFF98A2B3),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
