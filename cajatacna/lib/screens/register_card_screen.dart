import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_strings.dart';
import '../core/network/supabase_client.dart';
import '../providers/auth_provider.dart';

class RegisterCardScreen extends StatefulWidget {
  const RegisterCardScreen({super.key});

  @override
  State<RegisterCardScreen> createState() => _RegisterCardScreenState();
}

class _RegisterCardScreenState extends State<RegisterCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cardController = TextEditingController();
  final _documentController = TextEditingController();
  final _passwordController = TextEditingController();
  String _personType = 'Persona';
  String _documentType = 'DNI';
  bool _showPassword = false;
  bool _isCardRegisteredInDb = false;
  bool _checkingCard = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cardController.dispose();
    _documentController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkCardRegistration(String cardNumber) async {
    final digits = cardNumber.replaceAll(' ', '');
    if (digits.length != 16) return;
    setState(() {
      _checkingCard = true;
    });
    try {
      final last4 = digits.substring(12);
      final response = await SupabaseClient().post('/rest/v1/rpc/check_tarjeta_registrada', {
        'p_tarjeta_last4': last4,
      });
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty && data[0]['existe'] == true) {
          final profile = data[0];
          setState(() {
            _isCardRegisteredInDb = true;
            _nameController.text = profile['nombre_completo'] ?? '';
            _emailController.text = profile['email'] ?? '';
            _documentController.text = profile['numero_documento'] ?? '';
            _documentType = profile['tipo_documento'] ?? 'DNI';
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Esta tarjeta ya está registrada. Se cargaron los datos.'),
                backgroundColor: AppColors.azulPrincipal,
              ),
            );
          }
        } else {
          setState(() {
            _isCardRegisteredInDb = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking card registration: $e');
    } finally {
      setState(() {
        _checkingCard = false;
      });
    }
  }

  Future<void> _continue(AuthProvider authProvider) async {
    if (!_formKey.currentState!.validate()) return;

    if (_isCardRegisteredInDb) {
      final rawCard = _cardController.text.replaceAll(' ', '');
      final last4 = rawCard.substring(rawCard.length - 4);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppStrings.prefCardRegistered, true);
      await prefs.setString(AppStrings.prefCardLast4, last4);
      await prefs.setString(AppStrings.prefUserEmail, _emailController.text.trim());
      await prefs.setString(AppStrings.prefUserName, _nameController.text.trim());
      await prefs.setString(AppStrings.prefDocumentType, _documentType);
      await prefs.setString(AppStrings.prefDocumentNumber, _documentController.text.trim());

      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
      return;
    }

    final success = await authProvider.registerAccount(
      nombre: _nameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      numeroTarjeta: _cardController.text,
      tipoDocumento: _documentType,
      numeroDocumento: _documentController.text.trim(),
    );

    if (success && mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  void _showLoginSheet(BuildContext context, AuthProvider authProvider) {
    final cardController = TextEditingController();
    final pinController = TextEditingController();
    bool showPin = false;
    bool isLoading = false;
    String? errorMsg;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 24,
                right: 24,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.azulPrincipal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ingresa tu tarjeta y tu clave de internet para ingresar.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF667085),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Card Number
                    TextField(
                      controller: cardController,
                      keyboardType: TextInputType.number,
                      maxLength: 19,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CardNumberFormatter(),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Número de tarjeta',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 6-digit PIN
                    TextField(
                      controller: pinController,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      obscureText: !showPin,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Clave de internet (6 dígitos)',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        suffixIcon: IconButton(
                          icon: Icon(showPin ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setModalState(() {
                              showPin = !showPin;
                            });
                          },
                        ),
                      ),
                    ),
                    if (errorMsg != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorMsg!,
                        style: const TextStyle(
                          color: AppColors.rojoError,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () async {
                                final cardNum = cardController.text.replaceAll(' ', '');
                                final pin = pinController.text;
                                if (cardNum.length != 16) {
                                  setModalState(() {
                                    errorMsg = 'Ingresa los 16 dígitos de tu tarjeta.';
                                  });
                                  return;
                                }
                                if (pin.length != 6) {
                                  setModalState(() {
                                    errorMsg = 'La clave debe tener 6 dígitos.';
                                  });
                                  return;
                                }

                                setModalState(() {
                                  isLoading = true;
                                  errorMsg = null;
                                });

                                try {
                                  final last4 = cardNum.substring(cardNum.length - 4);
                                  // 1. Verificar la tarjeta mediante RPC
                                  final response = await SupabaseClient().post('/rest/v1/rpc/check_tarjeta_registrada', {
                                    'p_tarjeta_last4': last4,
                                  });

                                  if (response.statusCode == 200) {
                                    final List<dynamic> data = jsonDecode(response.body);
                                    if (data.isNotEmpty && data[0]['existe'] == true) {
                                      final profile = data[0];
                                      final email = profile['email'] ?? '';
                                      final nombre = profile['nombre_completo'] ?? '';
                                      final tipoDoc = profile['tipo_documento'] ?? 'DNI';
                                      final numDoc = profile['numero_documento'] ?? '';

                                      // 2. Realizar login con el email del perfil
                                      final success = await authProvider.login(email, pin);
                                      if (success) {
                                        // Guardar datos locales
                                        final prefs = await SharedPreferences.getInstance();
                                        await prefs.setBool(AppStrings.prefCardRegistered, true);
                                        await prefs.setString(AppStrings.prefCardLast4, last4);
                                        await prefs.setString(AppStrings.prefUserEmail, email);
                                        await prefs.setString(AppStrings.prefUserName, nombre);
                                        await prefs.setString(AppStrings.prefDocumentType, tipoDoc);
                                        await prefs.setString(AppStrings.prefDocumentNumber, numDoc);

                                        if (context.mounted) {
                                          Navigator.pop(context); // Cerrar bottom sheet
                                          Navigator.pushReplacementNamed(context, AppRoutes.home);
                                        }
                                      } else {
                                        setModalState(() {
                                          errorMsg = authProvider.error ?? 'Clave de internet incorrecta.';
                                          isLoading = false;
                                        });
                                      }
                                    } else {
                                      setModalState(() {
                                        errorMsg = 'Esta tarjeta no está registrada. Registra tu tarjeta primero.';
                                        isLoading = false;
                                      });
                                    }
                                  } else {
                                    setModalState(() {
                                      errorMsg = 'Error al verificar la tarjeta. Intenta de nuevo.';
                                      isLoading = false;
                                    });
                                  }
                                } catch (e) {
                                  setModalState(() {
                                    errorMsg = 'Error: $e';
                                    isLoading = false;
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.naranjaBCP,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Ingresar',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, _) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 720;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: Form(
                        key: _formKey,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            22,
                            compact ? 18 : 28,
                            22,
                            20,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset('assets/images/cajatacna.png',
                                      width: compact ? 108 : 124),
                                  IconButton(
                                    onPressed: () {},
                                    icon:
                                        const Icon(Icons.headset_mic_outlined),
                                    color: const Color(0xFF26374D),
                                    iconSize: 28,
                                  ),
                                ],
                              ),
                              SizedBox(height: compact ? 28 : 46),
                              Text(
                                '\u00a1Que bueno\ntenerte por aqui!',
                                style: TextStyle(
                                  color: AppColors.azulPrincipal,
                                  fontSize: compact ? 30 : 34,
                                  fontWeight: FontWeight.w800,
                                  height: 1.12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Completa tus datos para ingresar',
                                style: TextStyle(
                                  color: const Color(0xFF6B7280),
                                  fontSize: compact ? 16 : 18,
                                ),
                              ),
                              SizedBox(height: compact ? 22 : 30),
                              Row(
                                children: [
                                  _RadioChoice(
                                    label: 'Persona',
                                    selected: _personType == 'Persona',
                                    onTap: () =>
                                        setState(() => _personType = 'Persona'),
                                  ),
                                  const SizedBox(width: 28),
                                  _RadioChoice(
                                    label: 'Empresa',
                                    selected: _personType == 'Empresa',
                                    onTap: () =>
                                        setState(() => _personType = 'Empresa'),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              TextFormField(
                                controller: _nameController,
                                textCapitalization: TextCapitalization.words,
                                decoration: _fieldDecoration('Nombre completo'),
                                validator: (value) {
                                  if ((value ?? '').trim().length < 3) {
                                    return 'Ingresa tu nombre';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: _fieldDecoration('Correo'),
                                validator: (value) {
                                  final email = (value ?? '').trim();
                                  if (!email.contains('@') ||
                                      !email.contains('.')) {
                                    return 'Ingresa un correo valido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _cardController,
                                keyboardType: TextInputType.number,
                                maxLength: 19, // 16 dígitos + 3 espacios
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  _CardNumberFormatter(),
                                ],
                                onChanged: (value) {
                                  final digits = value.replaceAll(' ', '');
                                  if (digits.length == 16) {
                                    _checkCardRegistration(value);
                                  } else {
                                    if (_isCardRegisteredInDb) {
                                      setState(() {
                                        _isCardRegisteredInDb = false;
                                      });
                                    }
                                  }
                                },
                                decoration: _fieldDecoration(
                                  'Número de tarjeta de débito o crédito',
                                  counterText: '',
                                  suffixIcon: _checkingCard
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        )
                                      : null,
                                ),
                                validator: (value) {
                                  final digits = (value ?? '').replaceAll(' ', '');
                                  if (digits.length != 16) {
                                    return 'La tarjeta debe tener 16 dígitos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: DropdownButtonFormField<String>(
                                      value: _documentType,
                                      decoration: _fieldDecoration('Tipo'),
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'DNI',
                                          child: Text('DNI'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'CE',
                                          child: Text('CE'),
                                        ),
                                        DropdownMenuItem(
                                          value: 'RUC',
                                          child: Text('RUC'),
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() => _documentType = value);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 6,
                                    child: TextFormField(
                                      controller: _documentController,
                                      keyboardType: TextInputType.number,
                                      maxLength: _documentType == 'DNI'
                                          ? 8
                                          : _documentType == 'RUC'
                                              ? 11
                                              : 12,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: _fieldDecoration(
                                        'N° de documento',
                                        counterText: '',
                                      ),
                                      validator: (value) {
                                        final v = (value ?? '').trim();
                                        if (_documentType == 'DNI') {
                                          if (v.length != 8) {
                                            return 'El DNI debe tener 8 dígitos';
                                          }
                                        } else if (_documentType == 'RUC') {
                                          if (v.length != 11) {
                                            return 'El RUC debe tener 11 dígitos';
                                          }
                                        } else {
                                          if (v.length < 9) {
                                            return 'El CE debe tener mínimo 9 dígitos';
                                          }
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              if (!_isCardRegisteredInDb)
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_showPassword,
                                  keyboardType: TextInputType.number,
                                  maxLength: 6,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(6),
                                  ],
                                  decoration: _fieldDecoration(
                                    'Crea tu clave de 6 digitos',
                                    counterText: '',
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
                                    ),
                                  ),
                                  validator: (value) {
                                    if ((value ?? '').length != 6) {
                                      return 'La clave debe tener 6 digitos';
                                    }
                                    return null;
                                  },
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF81C784)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Color(0xFF388E3C)),
                                      SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Esta tarjeta ya está registrada en Supabase. Puedes continuar directamente para ingresar.',
                                          style: TextStyle(
                                            color: Color(0xFF2E7D32),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (authProvider.error != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  authProvider.error ?? '',
                                  style: const TextStyle(
                                    color: AppColors.rojoError,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 58,
                                child: ElevatedButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () => _continue(authProvider),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.naranjaBCP,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation(
                                              Colors.white,
                                            ),
                                          ),
                                        )
                                      : const Text(
                                          'Continuar',
                                          style: TextStyle(
                                            fontSize: 19,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: TextButton(
                                  onPressed: () => _showLoginSheet(context, authProvider),
                                  child: const Text(
                                    '¿Ya tienes una cuenta? Inicia sesión',
                                    style: TextStyle(
                                      color: AppColors.naranjaBCP,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(
    String label, {
    String? counterText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      counterText: counterText,
      suffixIcon: suffixIcon,
      labelStyle: const TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFC2C7D0), width: 1.2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.naranjaBCP, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.rojoError, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.rojoError, width: 1.6),
      ),
    );
  }
}


/// Formatea el número de tarjeta como XXXX XXXX XXXX XXXX mientras el usuario escribe.
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Solo dígitos, máx 16
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final trimmed = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < trimmed.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(trimmed[i]);
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _RadioChoice extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? AppColors.naranjaBCP : const Color(0xFFB7BDC7),
                width: 2.5,
              ),
            ),
            child: selected
                ? const Center(
                    child: CircleAvatar(
                      radius: 4,
                      backgroundColor: AppColors.naranjaBCP,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF2F3A4A),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
