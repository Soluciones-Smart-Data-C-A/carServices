// registration_step3.dart - VERSIÓN CON SNACKBAR UTILS
import 'package:flutter/material.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/utils/index.dart';
import 'package:car_service_app/views/registration/registration_step4.dart';

class RegistrationStep3 extends StatefulWidget {
  final String vehicleType;
  final String usageType;

  const RegistrationStep3({
    super.key,
    required this.vehicleType,
    required this.usageType,
  });

  @override
  State<RegistrationStep3> createState() => _RegistrationStep3State();
}

class _RegistrationStep3State extends State<RegistrationStep3> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _initialMileageController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  String _getVehicleTypeName() {
    final types = {
      'sedan': 'Sedán',
      'suv': 'SUV',
      'hatchback': 'Hatchback',
      'pickup': 'Pickup',
      'coupe': 'Coupé',
      'other': 'Otro',
    };
    return types[widget.vehicleType] ?? 'Desconocido';
  }

  String _getUsageTypeName() {
    final types = {
      'personal': 'Uso Personal',
      'transport': 'Transporte',
      'work': 'Trabajo',
    };
    return types[widget.usageType] ?? 'Desconocido';
  }

  String _generateOTP() {
    return (100000 + DateTime.now().millisecondsSinceEpoch % 900000).toString();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Simular proceso de registro y crear vehículo
        await Future.delayed(const Duration(seconds: 1));

        // Obtener el kilometraje inicial
        final initialMileage =
            int.tryParse(_initialMileageController.text) ?? 0;

        // Crear vehículo sin ID para que se autoincremente
        final vehicle = Vehicle(
          make: _getVehicleTypeName(),
          model: _getUsageTypeName(),
          initialMileage: initialMileage,
          currentMileage: initialMileage,
          lastServiceDate: DateTime.now(),
          lastServiceMileage: initialMileage,
          imageUrl: 'assets/images/chery_arauca.png',
        );

        await DatabaseService.addVehicle(vehicle);

        // Generar OTP simulado
        final otp = _generateOTP();

        if (mounted) {
          setState(() {
            _isLoading = false;
          });

          // Navegar al paso 4 de validación OTP
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RegistrationStep4(
                email: _emailController.text,
                phone: _phoneController.text,
                otpCode: otp,
              ),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          SnackBarUtils.showError(
            // REEMPLAZADO
            context: context,
            message: 'Error al registrar: $e',
          );
        }
      }
    }
  }

  // ELIMINADO: _showErrorDialog ya no es necesario

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header COMPACTO
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Paso 3 de 4',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Título COMPACTO
                const Text(
                  'Crear tu Cuenta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Completa tus datos para finalizar el registro',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 16),

                // Resumen de selección anterior COMPACTO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2AEFDA),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        color: Color(0xFF2AEFDA),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getVehicleTypeName(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              _getUsageTypeName(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Campos del formulario CON SCROLL
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        // Campo de kilometraje inicial
                        _buildTextField(
                          controller: _initialMileageController,
                          label: 'Kilometraje Inicial',
                          hintText: 'Ej: 15000',
                          prefixIcon: Icons.speed,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa el kilometraje inicial';
                            }
                            final mileage = int.tryParse(value);
                            if (mileage == null) {
                              return 'Ingresa un número válido';
                            }
                            if (mileage < 0) {
                              return 'El kilometraje no puede ser negativo';
                            }
                            if (mileage > 1000000) {
                              return 'El kilometraje parece demasiado alto';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _emailController,
                          label: 'Correo Electrónico',
                          hintText: 'ejemplo@correo.com',
                          prefixIcon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu correo';
                            }
                            if (!value.contains('@')) {
                              return 'Ingresa un correo válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Teléfono',
                          hintText: '+1234567890',
                          prefixIcon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa tu teléfono';
                            }
                            if (value.length < 8) {
                              return 'Ingresa un teléfono válido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _usernameController,
                          label: 'Usuario',
                          hintText: 'Crea un nombre de usuario',
                          prefixIcon: Icons.person,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un usuario';
                            }
                            if (value.length < 3) {
                              return 'El usuario debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _passwordController,
                          label: 'Contraseña',
                          hintText: 'Crea una contraseña segura',
                          prefixIcon: Icons.lock,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa una contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar Contraseña',
                          hintText: 'Repite tu contraseña',
                          prefixIcon: Icons.lock_outline,
                          obscureText: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor confirma tu contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Botón de registro - SIEMPRE VISIBLE
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2AEFDA),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.black,
                              ),
                            ),
                          )
                        : const Text(
                            'Registrar y Verificar',
                            style: TextStyle(
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
            prefixIcon: Icon(
              prefixIcon,
              color: const Color(0xFF75A6B1),
              size: 20,
            ),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF75A6B1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF75A6B1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF2AEFDA)),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            isDense: true,
          ),
          validator: validator,
        ),
      ],
    );
  }
}
