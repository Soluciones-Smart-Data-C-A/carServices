import 'package:flutter/material.dart';
import 'package:car_service_app/views/registration/registration_step3.dart';

class RegistrationStep2 extends StatefulWidget {
  const RegistrationStep2({super.key});

  @override
  State<RegistrationStep2> createState() => _RegistrationStep2State();
}

class _RegistrationStep2State extends State<RegistrationStep2> {
  String? _selectedVehicleType;
  String? _selectedUsageType;

  final List<Map<String, dynamic>> _vehicleTypes = [
    {'type': 'sedan', 'name': 'Sedán', 'icon': Icons.directions_car},
    {'type': 'suv', 'name': 'SUV', 'icon': Icons.airport_shuttle},
    {'type': 'hatchback', 'name': 'Hatchback', 'icon': Icons.directions_car},
    {'type': 'pickup', 'name': 'Pickup', 'icon': Icons.local_shipping},
    {'type': 'coupe', 'name': 'Coupé', 'icon': Icons.directions_car},
    {'type': 'other', 'name': 'Otro', 'icon': Icons.miscellaneous_services},
  ];

  final List<Map<String, dynamic>> _usageTypes = [
    {
      'type': 'personal',
      'name': 'Uso Personal',
      'description': 'Para uso familiar y personal',
      'icon': Icons.person,
    },
    {
      'type': 'transport',
      'name': 'Transporte',
      'description': 'Taxi, Uber, delivery o transporte comercial',
      'icon': Icons.local_taxi,
    },
    {
      'type': 'work',
      'name': 'Trabajo',
      'description': 'Uso profesional y de negocio',
      'icon': Icons.business_center,
    },
  ];

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
                    'Paso 2 de 3',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Título
              const Text(
                'Configura tu Vehículo',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona el tipo de vehículo y su uso principal',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),

              // Selección de tipo de vehículo
              const Text(
                'Tipo de Vehículo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Grid de tipos de vehículo
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: _vehicleTypes.length,
                        itemBuilder: (context, index) {
                          final vehicle = _vehicleTypes[index];
                          final isSelected =
                              _selectedVehicleType == vehicle['type'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedVehicleType =
                                    vehicle['type'] as String;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(
                                        0xFF2AEFDA,
                                      ).withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2AEFDA)
                                      : const Color(0xFF75A6B1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    vehicle['icon'] as IconData,
                                    size: 32,
                                    color: isSelected
                                        ? const Color(0xFF2AEFDA)
                                        : Colors.white,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    vehicle['name'] as String,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF2AEFDA)
                                          : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 40),

                      // Selección de tipo de uso
                      const Text(
                        'Uso del Vehículo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Column(
                        children: _usageTypes.map((usage) {
                          final isSelected =
                              _selectedUsageType == usage['type'];

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedUsageType = usage['type'] as String;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(
                                        0xFF2AEFDA,
                                      ).withValues(alpha: 0.2)
                                    : Colors.black.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF2AEFDA)
                                      : const Color(0xFF75A6B1),
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? const Color(0xFF2AEFDA)
                                          : const Color(0xFF75A6B1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      usage['icon'] as IconData,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          usage['name'] as String,
                                          style: TextStyle(
                                            color: isSelected
                                                ? const Color(0xFF2AEFDA)
                                                : Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          usage['description'] as String,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF2AEFDA),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Botón continuar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedVehicleType != null && _selectedUsageType != null
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RegistrationStep3(
                                vehicleType: _selectedVehicleType!,
                                usageType: _selectedUsageType!,
                              ),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _selectedVehicleType != null &&
                            _selectedUsageType != null
                        ? const Color(0xFF2AEFDA)
                        : Colors.grey,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Continuar',
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
}
