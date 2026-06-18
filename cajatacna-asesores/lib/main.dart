import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_routes.dart';
import 'core/network/supabase_client.dart';

// Repositorios
import 'repositories/auth_repository.dart';
import 'repositories/solicitud_repository.dart';
import 'repositories/cartera_repository.dart';
import 'repositories/buro_repository.dart';
import 'repositories/cobranza_repository.dart';

// Providers
import 'providers/auth_provider.dart';
import 'providers/solicitud_provider.dart';
import 'providers/cartera_provider.dart';
import 'providers/buro_provider.dart';
import 'providers/cobranza_provider.dart';

// Pantallas
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/solicitud_detalle_screen.dart';
import 'screens/cartera_screen.dart';
import 'screens/evaluacion_screen.dart';
import 'screens/cobranza_screen.dart';
import 'screens/reportes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Configurar orientación e inmersión de pantalla
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const CajaTacnaAsesoresApp());
}

class CajaTacnaAsesoresApp extends StatelessWidget {
  const CajaTacnaAsesoresApp({super.key});

  @override
  Widget build(BuildContext context) {
    final supabaseClient = SupabaseClient();
    final authRepo = AuthRepository(supabaseClient);
    final solicitudRepo = SolicitudRepository(supabaseClient);
    final carteraRepo = CarteraRepository(supabaseClient);
    final buroRepo = BuroRepository(supabaseClient);
    final cobranzaRepo = CobranzaRepository(supabaseClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepo, supabaseClient),
        ),
        ChangeNotifierProvider(
          create: (_) => SolicitudProvider(solicitudRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CarteraProvider(carteraRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => BuroProvider(buroRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CobranzaProvider(cobranzaRepo),
        ),
      ],
      child: MaterialApp(
        title: 'Caja Tacna para Asesores',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.azulPrincipal,
            primary: AppColors.azulPrincipal,
            secondary: AppColors.naranjaBCP,
          ),
          useMaterial3: true,
          visualDensity: VisualDensity.compact,
          scaffoldBackgroundColor: AppColors.fondoGrisClaro,
          textTheme: const TextTheme(
            displayMedium: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.azulPrincipal,
            ),
          ),
        ),
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (_) => const HomeScreen(),
          AppRoutes.detalleSolicitud: (_) => const SolicitudDetalleScreen(),
          AppRoutes.cartera: (_) => const CarteraScreen(),
          AppRoutes.evaluacion: (_) => const EvaluacionScreen(),
          AppRoutes.cobranza: (_) => const CobranzaScreen(),
          AppRoutes.reportes: (_) => const ReportesScreen(),
        },
      ),
    );
  }
}
