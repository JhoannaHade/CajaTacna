import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _passwordController = TextEditingController();
  String _cardLast4 = '1751';
  String _email = AppStrings.demoEmail;
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    _loadCard();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadCard() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cardLast4 = prefs.getString(AppStrings.prefCardLast4) ?? '1751';
      _email = prefs.getString(AppStrings.prefUserEmail) ?? AppStrings.demoEmail;
    });
  }

  void _showTokenAndLogoutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4E7EC),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Token Digital',
                    style: TextStyle(
                      color: AppColors.azulPrincipal,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Usa esta clave dinámica para autorizar tus operaciones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF667085),
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEAECF0)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '482 915',
                          style: TextStyle(
                            color: AppColors.azulPrincipal,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.timer_outlined, color: AppColors.naranjaBCP, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Se actualiza autom\u00e1ticamente cada 30 segundos',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        await _logoutAndClearCard();
                      },
                      icon: const Icon(Icons.logout, color: AppColors.rojoError),
                      label: const Text(
                        'Cerrar Sesión en este Dispositivo',
                        style: TextStyle(
                          color: AppColors.rojoError,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.rojoError),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _logoutAndClearCard() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppStrings.prefCardRegistered);
    await prefs.remove(AppStrings.prefCardLast4);
    await prefs.remove(AppStrings.prefDocumentType);
    await prefs.remove(AppStrings.prefDocumentNumber);
    await prefs.remove(AppStrings.prefUserEmail);
    await prefs.remove(AppStrings.prefUserId);
    await prefs.remove(AppStrings.prefToken);
    await prefs.remove(AppStrings.prefUserName);

    if (mounted) {
      context.read<AuthProvider>().logout();
      Navigator.pushReplacementNamed(context, AppRoutes.register);
    }
  }

  Future<void> _changeCard() async {
    // Mostrar opciones al usuario
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E7EC),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '¿Qué deseas hacer?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A2340),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige cómo quieres continuar',
              style: TextStyle(color: Color(0xFF667085), fontSize: 14),
            ),
            const SizedBox(height: 24),
            // Opción 1: Ingresar con otra cuenta ya registrada
            InkWell(
              onTap: () async {
                Navigator.pop(ctx);
                // Solo limpiamos la tarjeta guardada → vuelve a registrar tarjeta
                // para detectar si ya existe en la BD
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove(AppStrings.prefCardRegistered);
                await prefs.remove(AppStrings.prefCardLast4);
                await prefs.remove(AppStrings.prefUserEmail);
                await prefs.remove(AppStrings.prefUserName);
                await prefs.remove(AppStrings.prefDocumentType);
                await prefs.remove(AppStrings.prefDocumentNumber);
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.register);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEAECF0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.credit_card_outlined, color: AppColors.azulPrincipal, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ingresar con otra tarjeta',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A2340),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Ya tengo cuenta en Caja Tacna',
                            style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF667085)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Opción 2: Crear cuenta nueva
            InkWell(
              onTap: () async {
                Navigator.pop(ctx);
                // Limpiamos todo para registro completo nuevo
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, AppRoutes.register);
                }
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFEAECF0)),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_add_outlined, color: AppColors.naranjaBCP, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Registrar cuenta nueva',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF1A2340),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Agregar una tarjeta diferente',
                            style: TextStyle(color: Color(0xFF667085), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Color(0xFF667085)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _login(AuthProvider authProvider) async {
    if (_passwordController.text.length != 6) return;

    final success = await authProvider.login(
      _email,
      _passwordController.text,
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          final canLogin =
              _passwordController.text.length == 6 && !authProvider.isLoading;

          return Stack(
            children: [
              const _LoginHeader(),
              SafeArea(
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 18, 28, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Image.asset(
                            'assets/images/bcp_splash.png',
                            width: 112,
                          ),
                          Row(
                            children: [
                              _HeaderIcon(
                                icon: Icons.question_mark,
                                onTap: () {},
                              ),
                              const SizedBox(width: 12),
                              _HeaderIcon(
                                icon: Icons.phone,
                                onTap: () {},
                              ),
                              const SizedBox(width: 10),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.menu),
                                color: Colors.white,
                                iconSize: 30,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 84),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(28, 38, 28, 18),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              const Text(
                                'Hola',
                                style: TextStyle(
                                  color: AppColors.azulPrincipal,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                '\u00a1Qué bueno tenerte por aqu\u00ed!',
                                style: TextStyle(
                                  color: Color(0xFF344054),
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 24),
                              _QuickActions(onLogout: _showTokenAndLogoutSheet),
                              const SizedBox(height: 24),
                              _CardSummary(
                                last4: _cardLast4,
                                onChange: _changeCard,
                              ),
                              const SizedBox(height: 18),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_showPassword,
                                keyboardType: TextInputType.number,
                                maxLength: 6,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(6),
                                ],
                                onChanged: (_) => setState(() {}),
                                decoration: InputDecoration(
                                  counterText: '',
                                  hintText: 'Clave de internet de 6 d\u00edgitos',
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF687385),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    color: const Color(0xFF697386),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 22,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              if (authProvider.error != null) ...[
                                const SizedBox(height: 14),
                                Text(
                                  authProvider.error ?? '',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.rojoError,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed:
                                      canLogin ? () => _login(authProvider) : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.naranjaBCP,
                                    disabledBackgroundColor:
                                        const Color(0xFFEDEFF3),
                                    foregroundColor: Colors.white,
                                    disabledForegroundColor:
                                        const Color(0xFFC5CAD3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(32),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Ingresar',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextButton(
                                onPressed: () {},
                                child: const Text(
                                  '\u00bfOlvidaste tu clave?',
                                  style: TextStyle(
                                    color: AppColors.naranjaBCP,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'V.5.12.1',
                                style: TextStyle(
                                  color: Color(0xFFA2A8B3),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 248,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.azulPrincipal,
      ),
      child: Image.asset(
        'assets/images/bcp_header_bg.png',
        fit: BoxFit.cover,
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Colors.white,
        child: Icon(icon, color: AppColors.azulPrincipal, size: 20),
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onLogout;

  const _QuickActions({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final items = [
      (Icons.workspace_premium_outlined, 'Beneficios\nQore', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Beneficios Qore - Próximamente')),
        );
      }),
      (Icons.more_horiz, 'Token\nDigital', () {
        onLogout();
      }),
      (Icons.lock_outline, 'Bloquear\ntarjeta', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloquear tarjeta - Próximamente')),
        );
      }),
      (Icons.near_me_outlined, 'Yapear a\ncelular', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yapear a celular - Próximamente')),
        );
      }),
      (Icons.qr_code_scanner, 'Pagar\ncon QR', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pagar con QR - Próximamente')),
        );
      }),
      (Icons.water_drop_outlined, 'Pagar\nservicios', () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pagar servicios - Próximamente')),
        );
      }),
    ];

    return GridView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.02,
        mainAxisSpacing: 8,
        crossAxisSpacing: 14,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        return InkWell(
          onTap: item.$3,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppColors.naranjaBCP,
                child: Icon(item.$1, color: Colors.white, size: 27),
              ),
              const SizedBox(height: 6),
              Text(
                item.$2,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 13.5,
                  height: 1.12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _CardSummary extends StatelessWidget {
  final String last4;
  final VoidCallback onChange;

  const _CardSummary({
    required this.last4,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFC7CBD4), width: 1.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFF0F2F5),
            child: Icon(Icons.person, color: Color(0xFF687385)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Credimas d\u00e9bito',
                  style: TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '**** $last4',
                  style: const TextStyle(
                    color: Color(0xFF344054),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onChange,
            child: const Text(
              'Cambiar',
              style: TextStyle(
                color: AppColors.naranjaBCP,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
