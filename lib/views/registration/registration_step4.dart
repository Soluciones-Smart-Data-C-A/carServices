// registration_step4.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/services/registration_service.dart';

class RegistrationStep4 extends StatefulWidget {
  final String email;
  final String phone;
  final String otpCode;

  const RegistrationStep4({
    super.key,
    required this.email,
    required this.phone,
    required this.otpCode,
  });

  @override
  State<RegistrationStep4> createState() => _RegistrationStep4State();
}

class _RegistrationStep4State extends State<RegistrationStep4> {
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _otpFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _isResending = false;
  int _resendCountdown = 60;
  late String _currentOtp;
  bool _autoFilled = false; // NUEVO: Control para autocompletado

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otpCode;
    _setupOtpListeners();
    _startResendCountdown();
    _autoFillOTP(); // NUEVO: Autocompletar OTP después de un delay
  }

  // NUEVO: Método para autocompletar el OTP después de un delay
  void _autoFillOTP() async {
    await Future.delayed(Duration(seconds: 3)); // Esperar 3 segundos

    if (mounted && !_autoFilled) {
      setState(() {
        _autoFilled = true;
      });

      // Autocompletar los campos OTP
      for (int i = 0; i < _currentOtp.length; i++) {
        _otpControllers[i].text = _currentOtp[i];
      }

      // Mover foco al último campo
      if (_otpFocusNodes.length > 5) {
        _otpFocusNodes[5].requestFocus();
      }

      // Mostrar mensaje informativo
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Color(0xFF2AEFDA),
          content: Text(
            'Código OTP completado automáticamente para demo',
            style: TextStyle(color: Colors.black),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _setupOtpListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        if (_otpControllers[i].text.length == 1 && i < 5) {
          _otpFocusNodes[i + 1].requestFocus();
        }
      });

      _otpFocusNodes[i].addListener(() {
        if (_otpFocusNodes[i].hasFocus) {
          _otpControllers[i].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[i].text.length,
          );
        }
      });
    }
  }

  void _startResendCountdown() {
    Future.delayed(Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendCountdown();
      }
    });
  }

  void _resendOTP() async {
    if (_resendCountdown > 0) return;

    setState(() {
      _isResending = true;
      _autoFilled = false; // Resetear autocompletado
    });

    // Simular reenvío de OTP
    await Future.delayed(Duration(seconds: 2));

    // Generar nuevo OTP
    final newOtp = (100000 + DateTime.now().millisecondsSinceEpoch % 900000)
        .toString();

    setState(() {
      _currentOtp = newOtp;
      _isResending = false;
      _resendCountdown = 60;
    });

    _startResendCountdown();

    // Limpiar campos OTP
    for (final controller in _otpControllers) {
      controller.clear();
    }
    _otpFocusNodes[0].requestFocus();

    // Programar nuevo autocompletado
    _autoFillOTP();

    // Mostrar mensaje de éxito
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Color(0xFF2AEFDA),
        content: Text(
          'Nuevo código enviado',
          style: TextStyle(color: Colors.black),
        ),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _verifyOTP() async {
    final enteredOtp = _otpControllers
        .map((controller) => controller.text)
        .join();

    if (enteredOtp.length != 6) {
      _showErrorDialog('Por favor ingresa el código completo de 6 dígitos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Simular verificación
    await Future.delayed(Duration(seconds: 2));

    if (enteredOtp == _currentOtp) {
      // OTP correcto - completar registro
      await RegistrationService.setRegistrationCompleted(true);

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog(
        'Código incorrecto. Por favor verifica e intenta nuevamente.',
      );
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF10162A),
        title: Text(
          'Error de Verificación',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(message, style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Color(0xFF2AEFDA))),
          ),
        ],
      ),
    );
  }

  String _getMaskedEmail() {
    final parts = widget.email.split('@');
    if (parts.length != 2) return widget.email;

    final username = parts[0];
    final domain = parts[1];

    if (username.length <= 2) {
      return '${username[0]}***@$domain';
    }

    return '${username.substring(0, 2)}***@$domain';
  }

  String _getMaskedPhone() {
    if (widget.phone.length <= 4) return widget.phone;
    return '***${widget.phone.substring(widget.phone.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Paso 4 de 4',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                'Verifica tu Cuenta',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Ingresa el código de 6 dígitos que enviamos a:',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 16),

              // Información de contacto
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.email, color: Color(0xFF2AEFDA), size: 16),
                        SizedBox(width: 8),
                        Text(
                          _getMaskedEmail(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.phone, color: Color(0xFF2AEFDA), size: 16),
                        SizedBox(width: 8),
                        Text(
                          _getMaskedPhone(),
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    // NUEVO: Indicador de autocompletado
                    if (!_autoFilled) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color(0xFF2AEFDA),
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'El código se completará automáticamente en breve...',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Campos OTP
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 50,
                      child: TextField(
                        controller: _otpControllers[index],
                        focusNode: _otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Color(0xFF10162A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF75A6B1)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF75A6B1)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Color(0xFF2AEFDA)),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            _otpFocusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _otpFocusNodes[index - 1].requestFocus();
                          }
                        },
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),

              // Botón de reenviar
              Center(
                child: _isResending
                    ? CircularProgressIndicator(color: Color(0xFF2AEFDA))
                    : TextButton(
                        onPressed: _resendCountdown > 0 ? null : _resendOTP,
                        child: Text(
                          _resendCountdown > 0
                              ? 'Reenviar código en $_resendCountdown segundos'
                              : 'Reenviar código',
                          style: TextStyle(
                            color: _resendCountdown > 0
                                ? Colors.white54
                                : Color(0xFF2AEFDA),
                          ),
                        ),
                      ),
              ),

              const Spacer(),

              // Botón de verificación
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOTP,
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
                          'Verificar y Completar',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final controller in _otpControllers) {
      controller.dispose();
    }
    for (final focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}
