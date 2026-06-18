import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Pequeña demora para mostrar el splash
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final cardRegistered = prefs.getBool(AppStrings.prefCardRegistered) ?? false;

    // Si nunca registró tarjeta → onboarding
    if (!cardRegistered) {
      if (mounted) Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
      return;
    }

    // Si ya registró tarjeta → siempre solicitar clave de 6 dígitos al iniciar
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD21E20), Color(0xFF9E0B0E)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Transform.translate(
            offset: const Offset(0, 36),
            child: Image.asset(
              'assets/images/bcp_splash.png',
              width: 210,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
