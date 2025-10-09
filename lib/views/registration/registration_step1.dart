// registration_step1.dart - VERSIÓN CORREGIDA
import 'package:flutter/material.dart';
import 'package:car_service_app/views/registration/registration_step2.dart';

class RegistrationStep1 extends StatelessWidget {
  const RegistrationStep1({super.key});

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
                    'Paso 1 de 4',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                'Bienvenido a\nCar Service Pro',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 24),

              // Características - CON ALTURA FLEXIBLE
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildFeatureItem(
                        Icons.speed,
                        'Seguimiento de Kilometraje',
                        'Registro automático de distancia recorrida',
                      ),
                      _buildFeatureItem(
                        Icons.notifications,
                        'Recordatorios Inteligentes',
                        'Alertas para mantenimiento y servicios',
                      ),
                      _buildFeatureItem(
                        Icons.analytics,
                        'Historial Completo',
                        'Registro detallado de todos los servicios',
                      ),
                      _buildFeatureItem(
                        Icons.location_on,
                        'Ubicación en Tiempo Real',
                        'Seguimiento de viajes y distancias',
                      ),
                      const SizedBox(height: 20), // Espacio extra al final
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Botón continuar - AHORA SIEMPRE VISIBLE
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegistrationStep2(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2AEFDA),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Comenzar Registro',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2AEFDA).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2AEFDA), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
