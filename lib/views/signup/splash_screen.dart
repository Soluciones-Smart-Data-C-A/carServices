import 'package:flutter/material.dart';
import 'registration_step1.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  }); // Removido el parámetro onRegistrationComplete

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const RegistrationStep1()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo de la app
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFF2AEFDA),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.directions_car,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 32),
            // Nombre de la app
            const Text(
              'Car Service Pro',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            // Descripción
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Mantén tu vehículo en perfecto estado con nuestro sistema de seguimiento inteligente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2AEFDA)),
            ),
          ],
        ),
      ),
    );
  }
}
