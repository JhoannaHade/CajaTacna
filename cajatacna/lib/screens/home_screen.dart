import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../providers/cuenta_provider.dart';
import '../providers/perfil_provider.dart';
import '../widgets/app_scaffold.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _userName = '';
  bool _saldoVisible = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _userName = prefs.getString(AppStrings.prefUserName) ?? '';
      });
    }

    if (!mounted) return;
    final authProvider = context.read<AuthProvider>();
    final cuentaProvider = context.read<CuentaProvider>();
    final perfilProvider = context.read<PerfilProvider>();
    final userId = authProvider.currentUser?.id;
    if (userId != null) {
      cuentaProvider.cargarCuentas();
      perfilProvider.cargarPerfil(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Caja Tacna',
      currentIndex: 0,
      body: Consumer2<PerfilProvider, CuentaProvider>(
        builder: (context, perfilProvider, cuentaProvider, _) {
          final nombre = perfilProvider.perfil?.nombreCompleto ?? _userName;
          final primerNombre = nombre.isNotEmpty
              ? nombre.split(' ').first
              : 'Usuario';

          return RefreshIndicator(
            onRefresh: () async {
              final authProvider = context.read<AuthProvider>();
              final cuentaProvider = context.read<CuentaProvider>();
              final perfilProvider = context.read<PerfilProvider>();
              final userId = authProvider.currentUser?.id;
              if (userId != null) {
                await cuentaProvider.cargarCuentas();
                await perfilProvider.cargarPerfil(userId);
              }
            },
            color: AppColors.naranjaBCP,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildHeader(primerNombre),
                  _buildTusProductos(cuentaProvider),
                  const SizedBox(height: 8),
                  _buildQuickActions(context),
                  const SizedBox(height: 8),
                  _buildLoMasDestacado(),
                  const SizedBox(height: 8),
                  _buildPromocionesExclusivas(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(String name) {
    return Container(
      color: AppColors.azulPrincipal,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo Caja Tacna
              const Text(
                'Caja Tacna',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              // Icons ? and bell
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                    onPressed: () {},
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_none_outlined, color: Colors.white, size: 24),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.naranjaBCP,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Hola, ${name.toUpperCase()}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTusProductos(CuentaProvider cuentaProvider) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Tus productos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulPrincipal,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  _saldoVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppColors.azulPrincipal,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _saldoVisible = !_saldoVisible;
                  });
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.edit_outlined,
                  color: AppColors.azulPrincipal,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (cuentaProvider.isLoading && cuentaProvider.cuentas.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (cuentaProvider.cuentas.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'No se encontraron cuentas activas.',
                style: TextStyle(color: AppColors.grisTexto),
              ),
            )
          else
            ...cuentaProvider.cuentas.map((cuenta) {
              final last4 = cuenta.numeroCuenta.length >= 4
                  ? cuenta.numeroCuenta.substring(cuenta.numeroCuenta.length - 4)
                  : 'xxxx';
              final isDolar = cuenta.tipo.toLowerCase().contains('dolar') ||
                  cuenta.tipo.toLowerCase().contains('dollar') ||
                  cuenta.tipo.toLowerCase().contains('usd');
              return Column(
                children: [
                  InkWell(
                    onTap: () {
                      cuentaProvider.cargarTransacciones(cuenta.id);
                      Navigator.pushNamed(context, AppRoutes.cuenta, arguments: cuenta);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          // CAJATACNA Dual-colored Logo Shape
                          SizedBox(
                            width: 32,
                            height: 32,
                            child: CustomPaint(
                              painter: CajaTacnaMiniLogoPainter(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  cuenta.tipo.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.azulPrincipal,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '**** $last4',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF98A2B3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                _saldoVisible
                                    ? '${isDolar ? 'US\$' : 'S/'} ${cuenta.saldo.toStringAsFixed(2)}'
                                    : '${isDolar ? 'US\$' : 'S/'} *****',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.azulPrincipal,
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
                  ),
                  const Divider(height: 1, color: Color(0xFFF2F4F7)),
                ],
              );
            }).toList(),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.cuenta);
              },
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  color: AppColors.naranjaBCP,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      (Icons.send_rounded, 'Yapear a\ncelular', AppRoutes.transferencias),
      (Icons.qr_code_scanner, 'Pagar\ncon QR', AppRoutes.pagos),
      (Icons.water_drop_outlined, 'Pagar\nservicios', AppRoutes.pagos),
      (Icons.swap_horiz, 'Transferir\ndinero', AppRoutes.transferencias),
    ];

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: actions.map((item) {
          return InkWell(
            onTap: () => Navigator.pushNamed(context, item.$3),
            child: Column(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: AppColors.naranjaBCP,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.$1, color: Colors.white, size: 24),
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
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoMasDestacado() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Lo más destacado',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.azulPrincipal,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildDestacadoCard(
                  title: 'Descubre Qore',
                  subtitle: 'Tu nueva zona de beneficios',
                  tag: 'Nuevo',
                  icon: Icons.search,
                ),
                _buildDestacadoCard(
                  title: 'Cambia soles y dólares',
                  subtitle: '¡Con el mejor tipo de cambio!',
                  tag: null,
                  icon: Icons.currency_exchange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: AppColors.azulSecundario,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              ...List.generate(6, (i) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDestacadoCard({
    required String title,
    required String subtitle,
    String? tag,
    required IconData icon,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F4F7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.azulClaro,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.azulPrincipal, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulPrincipal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF667085),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (tag != null)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.naranjaBCP,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPromocionesExclusivas() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Promociones exclusivas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.azulPrincipal,
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: AppColors.naranjaBCP,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Banner Superhero card
          Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE6F0FA), Color(0xFFCBE0F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 16,
                  bottom: 0,
                  top: 8,
                  child: Image.asset(
                    'web/favicon.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.card_giftcard,
                      size: 64,
                      color: AppColors.azulPrincipal,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  top: 20,
                  bottom: 20,
                  right: 120,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        '¡Llegó tu momento de brillar!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.azulPrincipal,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Paga con tu tarjeta Caja Tacna y participa por increíbles premios semanales.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.azulPrincipal,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CajaTacnaMiniLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintRed = Paint()
      ..color = const Color(0xFFD21E20)
      ..style = PaintingStyle.fill;

    // 1. Top circle
    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.2), size.width * 0.12, paintRed);

    // 2. Top horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.38, size.width * 0.7, size.height * 0.08),
        Radius.circular(size.width * 0.02),
      ),
      paintRed,
    );

    // 3. Left vertical column
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.22, size.height * 0.46, size.width * 0.1, size.height * 0.32),
      paintRed,
    );

    // 4. Right vertical column
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.68, size.height * 0.46, size.width * 0.1, size.height * 0.32),
      paintRed,
    );

    // 5. Middle horizontal bar
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.32, size.height * 0.58, size.width * 0.36, size.height * 0.08),
      paintRed,
    );

    // 6. Bottom horizontal bar
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(size.width * 0.15, size.height * 0.78, size.width * 0.7, size.height * 0.08),
        Radius.circular(size.width * 0.02),
      ),
      paintRed,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
