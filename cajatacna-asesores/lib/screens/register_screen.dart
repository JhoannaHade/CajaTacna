import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  String _documentType = 'DNI';
  bool _showPassword = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _documentController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.registerAdvisorAccount(
      nombre: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      tipoDocumento: _documentType,
      numeroDocumento: _documentController.text.trim(),
      telefono: _phoneController.text.trim(),
      direccion: _addressController.text.trim(),
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cuenta de Asesor creada exitosamente.'),
          backgroundColor: AppColors.verdeExito,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registro de Asesores Caja Tacna',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: AppColors.azulPrincipal,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Crear nueva cuenta de Asesor',
                style: TextStyle(
                  color: AppColors.azulPrincipal,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresa tus datos personales y corporativos para registrarte.',
                style: TextStyle(color: Color(0xFF667085), fontSize: 14),
              ),
              const SizedBox(height: 24),

              // Nombre
              _buildLabel('Nombre Completo'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa tu nombre';
                  if (val.trim().length < 3) return 'Debe tener al menos 3 caracteres';
                  return null;
                },
                decoration: _inputDecoration('Ej. Juan Pérez', Icons.person_outline),
              ),
              const SizedBox(height: 16),

              // Correo
              _buildLabel('Correo Corporativo'),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa tu correo';
                  if (!val.contains('@')) return 'Ingresa un correo válido';
                  return null;
                },
                decoration: _inputDecoration('Ej. jperez@cajatacna.com.pe', Icons.email_outlined),
              ),
              const SizedBox(height: 16),

              // Contraseña
              _buildLabel('Contraseña de Acceso'),
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                maxLength: 6,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Ingresa tu contraseña';
                  if (val.length != 6) return 'Debe tener exactamente 6 dígitos';
                  return null;
                },
                decoration: _inputDecoration('Clave numérica de 6 dígitos', Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(_showPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _showPassword = !_showPassword),
                      color: const Color(0xFF667085),
                    )),
              ),
              const SizedBox(height: 8),

              // Documento
              _buildLabel('Documento de Identidad'),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _documentType,
                      decoration: _dropdownDecoration(),
                      items: const [
                        DropdownMenuItem(value: 'DNI', child: Text('DNI')),
                        DropdownMenuItem(value: 'CE', child: Text('CE')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _documentType = val;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 7,
                    child: TextFormField(
                      controller: _documentController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return 'Requerido';
                        if (_documentType == 'DNI' && val.trim().length != 8) {
                          return 'El DNI debe tener 8 dígitos';
                        }
                        if (_documentType == 'CE' && val.trim().length < 9) {
                          return 'El CE debe tener min 9 dígitos';
                        }
                        return null;
                      },
                      decoration: _inputDecoration('Número', Icons.badge_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Teléfono
              _buildLabel('Teléfono Corporativo / Personal'),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa tu teléfono';
                  if (val.trim().length < 9) return 'Debe tener al menos 9 dígitos';
                  return null;
                },
                decoration: _inputDecoration('Ej. 999888777', Icons.phone_outlined),
              ),
              const SizedBox(height: 16),

              // Dirección
              _buildLabel('Dirección de la Sucursal Caja Tacna'),
              TextFormField(
                controller: _addressController,
                textCapitalization: TextCapitalization.words,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Ingresa la dirección';
                  return null;
                },
                decoration: _inputDecoration('Ej. Av. Larco 456, Miraflores', Icons.location_on_outlined),
              ),

              if (authProvider.error != null) ...[
                const SizedBox(height: 20),
                Text(
                  authProvider.error ?? '',
                  style: const TextStyle(color: AppColors.rojoError, fontWeight: FontWeight.bold),
                ),
              ],

              const SizedBox(height: 32),

              // Botón Registrarse
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: authProvider.isLoading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.azulPrincipal,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: const Color(0xFFEDEFF3),
                    disabledForegroundColor: const Color(0xFFC5CAD3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: authProvider.isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Registrar Cuenta',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.azulPrincipal,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.azulPrincipal),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      counterText: '',
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.azulPrincipal, width: 2),
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.azulPrincipal, width: 2),
      ),
    );
  }
}
