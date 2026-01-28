// registration_step4.dart - VERSIÓN CON SNACKBAR UTILS
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/utils/index.dart'; // NUEVO IMPORT

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
  bool _isOtpComplete = false;

  @override
  void initState() {
    super.initState();
    _currentOtp = widget.otpCode;
    _setupOtpListeners();
    _startResendCountdown();
    _autoFillOTP();
  }

  void _autoFillOTP() async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      for (
        int i = 0;
        i < _otpControllers.length && i < _currentOtp.length;
        i++
      ) {
        _otpControllers[i].text = _currentOtp[i];
      }
      setState(() {});
      _checkOtpCompletion();
    }
  }

  void _setupOtpListeners() {
    for (int i = 0; i < _otpControllers.length; i++) {
      _otpControllers[i].addListener(() {
        final text = _otpControllers[i].text;
        if (text.length == 1 && i < _otpControllers.length - 1) {
          _otpFocusNodes[i + 1].requestFocus();
        } else if (text.isEmpty && i > 0) {
          Future.microtask(() => _otpFocusNodes[i - 1].requestFocus());
        }
        _checkOtpCompletion();
      });
    }
  }

  void _checkOtpCompletion() {
    final fullOtp = _otpControllers.map((c) => c.text).join();
    setState(() {
      _isOtpComplete = fullOtp.length == 6;
    });
  }

  void _startResendCountdown() {
    // Implementación de cuenta regresiva
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
        _startResendCountdown();
      }
    });
  }

  // ELIMINADO: _showSnackBar ya no es necesario

  Future<void> _verifyOTP() async {
    if (!_isOtpComplete || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    final enteredOtp = _otpControllers.map((c) => c.text).join();

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (enteredOtp == _currentOtp) {
      SnackBarUtils.showSuccess(
        // REEMPLAZADO
        context: context,
        message: 'Verificación exitosa. Registro completado!',
      );

      // Navegar a MainScreen después de un breve delay
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    } else {
      SnackBarUtils.showError(
        // REEMPLAZADO
        context: context,
        message: 'Código OTP incorrecto. Inténtalo de nuevo.',
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 48,
      child: TextFormField(
        controller: _otpControllers[index],
        focusNode: _otpFocusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: const Color(0xFF1B2232),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF75A6B1)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF75A6B1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF2AEFDA), width: 2),
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton() {
    final canResend = _resendCountdown == 0 && !_isResending;
    return TextButton(
      onPressed: canResend
          ? () async {
              setState(() {
                _isResending = true;
                _resendCountdown = 60;
              });

              await Future.delayed(const Duration(seconds: 2));

              if (!mounted) return;

              setState(() {
                _isResending = false;
              });
              _startResendCountdown();
              SnackBarUtils.showSuccess(
                // REEMPLAZADO
                context: context,
                message: 'Nuevo código OTP enviado a ${widget.email}',
              );
            }
          : null,
      child: Text(
        canResend
            ? 'Reenviar Código'
            : _isResending
            ? 'Enviando...'
            : 'Reenviar en ${_resendCountdown}s',
        style: TextStyle(
          color: canResend ? const Color(0xFF2AEFDA) : Colors.white54,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      margin: const EdgeInsets.only(top: 32, bottom: 24),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isOtpComplete && !_isLoading ? _verifyOTP : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2AEFDA),
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 2,
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Text(
                'Verificar y Completar',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      body: SafeArea(
        child: SingleChildScrollView(
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

              // Título y Descripción
              const Text(
                'Verificación de Código OTP',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Hemos enviado un código de 6 dígitos a su correo ${widget.email}. Ingréselo a continuación para continuar.',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 48),

              // Campos OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  _otpControllers.length,
                  (index) => _buildOtpField(index),
                ),
              ),
              const SizedBox(height: 24),

              // Botón de reenviar
              Center(child: _buildResendButton()),

              // Botón de verificar - AHORA DENTRO DEL CONTENIDO
              _buildVerifyButton(),

              // Espacio adicional para evitar que el teclado cubra el contenido
              const SizedBox(height: 20),
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
