import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/network/supabase_client.dart';
import 'repositories/auth_repository.dart';
import 'repositories/cuenta_repository.dart';
import 'repositories/ahorro_repository.dart';
import 'repositories/credito_repository.dart';
import 'repositories/perfil_repository.dart';
import 'providers/auth_provider.dart';
import 'providers/cuenta_provider.dart';
import 'providers/ahorro_provider.dart';
import 'providers/credito_provider.dart';
import 'providers/perfil_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/register_card_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ahorro_screen.dart';
import 'screens/creditos_screen.dart';
import 'screens/transferencias_screen.dart';
import 'screens/pagos_screen.dart';
import 'screens/perfil_screen.dart';
import 'screens/opera_screen.dart';
import 'screens/notifica_screen.dart';
import 'screens/contacto_screen.dart';
import 'screens/cuenta_screen.dart';
import 'screens/tarjeta_screen.dart';
import 'screens/prestamo_screen.dart';
import 'repositories/solicitud_repository.dart';
import 'providers/solicitud_provider.dart';
import 'screens/solicitar_prestamo_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Pantalla completa: oculta barra de estado y botones del sistema
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const CajaTacnaApp());
}

class CajaTacnaApp extends StatelessWidget {
  const CajaTacnaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = SupabaseClient();
    final authRepo = AuthRepository(supabaseClient);
    final cuentaRepo = CuentaRepository(supabaseClient);
    final ahorroRepo = AhorroRepository(supabaseClient);
    final creditoRepo = CreditoRepository(supabaseClient);
    final perfilRepo = PerfilRepository(supabaseClient);
    final solicitudRepo = SolicitudRepository(supabaseClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepo, supabaseClient),
        ),
        ChangeNotifierProvider(
          create: (_) => CuentaProvider(cuentaRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => AhorroProvider(ahorroRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CreditoProvider(creditoRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => PerfilProvider(perfilRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SolicitudProvider(solicitudRepo),
        ),
      ],
      child: MaterialApp(
        title: 'Caja Tacna',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme:
              ColorScheme.fromSeed(seedColor: AppColors.azulPrincipal),
          useMaterial3: true,
          visualDensity: VisualDensity.compact,
          scaffoldBackgroundColor: AppColors.fondoGrisClaro,
          textTheme: const TextTheme(
            displayMedium: TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.onboarding: (_) => const OnboardingScreen(),
          AppRoutes.register: (_) => const RegisterCardScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.ahorro: (_) => const AhorroScreen(),
          AppRoutes.creditos: (_) => const CreditosScreen(),
          AppRoutes.transferencias: (_) => const TransferenciasScreen(),
          AppRoutes.pagos: (_) => const PagosScreen(),
          AppRoutes.perfil: (_) => const PerfilScreen(),
          AppRoutes.opera: (_) => const OperaScreen(),
          AppRoutes.notifica: (_) => const NotificaScreen(),
          AppRoutes.contacto: (_) => const ParaTiScreen(),
          AppRoutes.cuenta: (_) => const CuentaScreen(),
          AppRoutes.tarjeta: (_) => const TarjetaScreen(),
          AppRoutes.prestamo: (_) => const PrestamoScreen(),
          AppRoutes.solicitarPrestamo: (_) => const SolicitarPrestamoScreen(),
        },
      ),
    );
  }
}
