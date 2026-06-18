import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../providers/auth_provider.dart';
import '../core/network/supabase_client.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;

  @override
  void initState() {
    super.initState();
    // Autorellenar con credencial de asesor demo para conveniencia en pruebas
    _emailController.text = 'asesor@cajatacna.com.pe';
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    
    final success = await authProvider.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (success && mounted) {
      // Verificar si es asesor real en la base de datos
      try {
        final client = SupabaseClient();
        final response = await client.get('/rest/v1/perfiles', query: {
          'user_id': 'eq.${authProvider.currentUser?.id}',
          'select': 'es_asesor,nombre_completo',
        });

        bool isAsesor = false;
        String nombreAsesor = 'Asesor Caja Tacna';

        if (response.statusCode == 200) {
          final List data = jsonDecode(response.body);
          if (data.isNotEmpty) {
            isAsesor = data.first['es_asesor'] == true;
            nombreAsesor = data.first['nombre_completo'] ?? 'Asesor Caja Tacna';
          }
        }

        if (isAsesor) {
          // Guardar el nombre del asesor en cache local
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppStrings.prefUserName, nombreAsesor);

          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        } else {
          // No es asesor -> Cerrar sesión forzado
          await authProvider.logout();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Acceso Denegado: Su cuenta no cuenta con permisos de Asesor.'),
                backgroundColor: AppColors.rojoError,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } catch (e) {
        await authProvider.logout();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al validar credenciales de asesor: $e'),
              backgroundColor: AppColors.rojoError,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Encabezado corporativo
            Container(
              width: double.infinity,
              height: 260,
              decoration: const BoxDecoration(
                color: AppColors.azulPrincipal,
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(80),
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Caja Tacna
                      const Text(
                        'Caja Tacna',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Portal de Asesores',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Ingresa con tus credenciales bancarias autorizadas.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Formulario de login
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 40, 32, 20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Correo Electrónico',
                      style: TextStyle(
                        color: AppColors.azulPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Por favor ingresa tu correo corporativo';
                        }
                        if (!value.contains('@')) {
                          return 'Formato de correo inválido';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: 'ejemplo@cajatacna.com.pe',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.azulPrincipal),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.azulPrincipal, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        color: AppColors.azulPrincipal,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingresa tu contraseña';
                        }
                        if (value.length < 6) {
                          return 'La contraseña debe tener al menos 6 caracteres';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: '******',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppColors.azulPrincipal),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                          icon: Icon(
                            _showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: const Color(0xFF667085),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.azulPrincipal, width: 2),
                        ),
                      ),
                    ),
                    
                    if (authProvider.error != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.rojoError.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: AppColors.rojoError),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                authProvider.error ?? '',
                                style: const TextStyle(
                                  color: AppColors.rojoError,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 36),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: authProvider.isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.azulPrincipal,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFEDEFF3),
                          disabledForegroundColor: const Color(0xFFC5CAD3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          elevation: 1,
                        ),
                        child: authProvider.isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  valueColor: AlwaysStoppedAnimation(Colors.white),
                                ),
                              )
                            : const Text(
                                'Iniciar Sesión',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.register);
                        },
                        child: const Text(
                          '¿No tienes cuenta de Asesor? Regístrate aquí',
                          style: TextStyle(
                            color: AppColors.naranjaBCP,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 40),
            const Text(
              'Portal Interno Caja Tacna Asesores • v1.0.0',
              style: TextStyle(
                color: Color(0xFF98A2B3),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
