// services.dart (with automatic mileage feature and translations)
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/models/service_record.dart';
import 'package:car_service_app/models/service.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/location_service.dart';
import 'package:car_service_app/services/app_localizations.dart';

class ServicesView extends StatefulWidget {
  // AJUSTE: Parámetros opcionales para inicializar con datos
  final String? serviceName;
  final int? serviceId;

  const ServicesView({super.key, this.serviceName, this.serviceId});

  @override
  ServicesViewState createState() => ServicesViewState();
}

class ServicesViewState extends State<ServicesView> {
  // Controllers
  final TextEditingController _mileageController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  static final Logger _logger = Logger();

  // State
  Map<int, bool> _selectedServices = {};
  List<Service> _availableServices = [];
  Map<int, String> _serviceIcons = {};
  Vehicle? _selectedVehicle;
  bool _hasServices = false;
  bool _isLocationEnabled = false;
  double _autoMileage = 0.0;

  // Futures
  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<Map<String, dynamic>> _servicesDataFuture;

  // Constants
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _backgroundColor = Colors.transparent;
  static const _textColor = Colors.white;
  static const _grey300 = Color(0xFFE0E0E0);
  static const _grey400 = Color(0xFFBDBDBD);

  @override
  void initState() {
    super.initState();
    _logger.i('ServicesView initialized');
    if (widget.serviceId != null) {
      _hasServices = true;
    }
    _initializeData();
    _checkLocationStatus();
  }

  void _initializeData() {
    _vehiclesFuture = DatabaseService.getVehicles();
    _servicesDataFuture = _loadServicesData();
  }

  void _checkLocationStatus() async {
    final locationService = LocationService();
    final hasPermission = await locationService.checkLocationPermission();

    setState(() {
      _isLocationEnabled = hasPermission;
      if (_isLocationEnabled && locationService.isTracking) {
        _autoMileage = locationService.todayDistance;
      }
    });
  }

  Future<Map<String, dynamic>> _loadServicesData() async {
    try {
      final services = await DatabaseService.getServices();
      final servicesWithIcons = await DatabaseService.getServicesWithIcons();

      final Map<int, String> iconMap = {};
      for (var serviceData in servicesWithIcons) {
        iconMap[serviceData['id'] as int] = serviceData['iconData'] as String;
      }

      final Map<int, bool> selectionMap = {};
      for (var service in services) {
        _logger.i(
          'Checking service: ${service.serviceName} with ID: ${service.id}',
        );
        selectionMap[service.id!] = (widget.serviceId == service.id);
      }

      return {
        'services': services,
        'icons': iconMap,
        'selection': selectionMap,
      };
    } catch (e) {
      _logger.i('Error loading services data: $e');
      return {'services': [], 'icons': {}, 'selection': {}};
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : _primaryColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _useAutoMileage(AppLocalizations localizations) async {
    if (!_isLocationEnabled) {
      _showSnackBar(localizations.autoMileageUnavailable, isError: true);
      return;
    }

    if (_selectedVehicle == null) {
      _showSnackBar(localizations.selectVehicleFirst, isError: true);
      return;
    }

    final locationService = LocationService();
    final currentAutoMileage = locationService.todayDistance;
    final estimatedMileage =
        _selectedVehicle!.currentMileage + currentAutoMileage.round();

    setState(() {
      _mileageController.text = estimatedMileage.toString();
      _autoMileage = currentAutoMileage;
    });

    _showSnackBar(
      localizations.autoMileageSet(
        estimatedMileage,
        currentAutoMileage.toStringAsFixed(1),
      ),
    );
  }

  bool _validateInputs(AppLocalizations localizations) {
    if (_selectedVehicle == null || _mileageController.text.isEmpty) {
      _showSnackBar(localizations.selectVehicleAndMileage, isError: true);
      return false;
    }

    final mileage = int.tryParse(_mileageController.text) ?? 0;
    if (mileage == 0) {
      _showSnackBar(localizations.enterValidMileage, isError: true);
      return false;
    }

    if (mileage < _selectedVehicle!.currentMileage) {
      _showSnackBar(
        localizations.mileageCannotBeLess(_selectedVehicle!.currentMileage),
        isError: true,
      );
      return false;
    }

    if (_hasServices) {
      final selectedServiceIds = _selectedServices.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      if (selectedServiceIds.isEmpty) {
        _showSnackBar(localizations.selectAtLeastOneService, isError: true);
        return false;
      }
    }

    return true;
  }

  Future<void> _saveRecord(AppLocalizations localizations) async {
    if (!_validateInputs(localizations)) return;

    final mileage = int.parse(_mileageController.text);
    List<int> selectedServiceIds = [];

    if (_hasServices) {
      selectedServiceIds = _selectedServices.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();
    }

    try {
      if (_hasServices && selectedServiceIds.isNotEmpty) {
        await _saveServiceRecords(mileage, selectedServiceIds);
      }

      await _updateVehicleData(mileage);

      _showSnackBar(localizations.serviceRecordSaved);
      _resetForm();
    } catch (e) {
      _showSnackBar(
        localizations.errorSavingRecord(e.toString()),
        isError: true,
      );
    }
  }

  Future<void> _saveServiceRecords(int mileage, List<int> serviceIds) async {
    for (final serviceId in serviceIds) {
      final newRecord = ServiceRecord(
        vehicleId: _selectedVehicle!.id!,
        serviceId: serviceId,
        mileage: mileage,
        date: DateTime.now(),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );
      await DatabaseService.addServiceRecord(newRecord);
    }
  }

  Future<void> _updateVehicleData(int mileage) async {
    final updatedVehicle = Vehicle(
      id: _selectedVehicle!.id,
      make: _selectedVehicle!.make,
      model: _selectedVehicle!.model,
      initialMileage: _selectedVehicle!.initialMileage,
      currentMileage: mileage > _selectedVehicle!.currentMileage
          ? mileage
          : _selectedVehicle!.currentMileage,
      lastServiceDate: DateTime.now(),
      lastServiceMileage: mileage,
    );

    await DatabaseService.updateVehicle(updatedVehicle);
    _vehiclesFuture = DatabaseService.getVehicles();
  }

  void _resetForm() {
    _mileageController.clear();
    _notesController.clear();
    setState(() {
      _hasServices = false;
      _selectedServices = _selectedServices.map(
        (key, value) => MapEntry(key, false),
      );
    });
  }

  IconData _getIconForService(String iconName) {
    const iconMap = {
      'oil_change': Icons.local_car_wash,
      'air_filter': Icons.air,
      'brakes': Icons.fiber_manual_record,
      'tire_rotation': Icons.rotate_right,
      'alignment': Icons.straighten,
      'battery': Icons.battery_charging_full,
      'timing_belt': Icons.settings,
      'car_wash': Icons.local_car_wash,
      'engine': Icons.engineering,
      'suspension': Icons.airline_seat_recline_normal,
    };
    return iconMap[iconName] ?? Icons.build;
  }

  Widget _buildServiceCard(Service service) {
    final iconName = _serviceIcons[service.id] ?? 'default_icon';
    final isSelected = _selectedServices[service.id] ?? false;

    return GestureDetector(
      onTap: () => setState(() => _selectedServices[service.id!] = !isSelected),
      child: Container(
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _primaryColor : _secondaryColor,
            width: isSelected ? 3 : 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              child: Icon(
                _getIconForService(iconName),
                size: 32,
                color: _textColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                service.serviceName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, bool isSelected) {
    String getImagePath() {
      if (vehicle.imageUrl != null && vehicle.imageUrl!.isNotEmpty) {
        return vehicle.imageUrl!;
      }
      if (vehicle.make == 'Chery' && vehicle.model == 'Arauca') {
        return 'assets/images/chery_arauca.png';
      } else if (vehicle.make == 'Toyota' && vehicle.model == 'Corolla') {
        return 'assets/images/toyota_corolla.png';
      }
      return 'assets/images/default_car.png';
    }

    return Card(
      color: isSelected
          ? Colors.black.withOpacity(0.5)
          : Colors.black.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? _primaryColor : _secondaryColor,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Image.asset(
              getImagePath(),
              width: 70,
              height: 70,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.directions_car,
                  size: 70,
                  color: Colors.white70,
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${vehicle.make} ${vehicle.model}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${vehicle.currentMileage} km",
                    style: const TextStyle(
                      fontSize: 14,
                      color: _primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (_isLocationEnabled)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _primaryColor.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on,
                  color: _primaryColor,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection(List<Vehicle> vehicles) {
    return SizedBox(
      height: 90,
      child: PageView.builder(
        controller: PageController(viewportFraction: 1.0),
        itemCount: vehicles.length,
        onPageChanged: (index) =>
            setState(() => _selectedVehicle = vehicles[index]),
        itemBuilder: (context, index) {
          final vehicle = vehicles[index];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            child: GestureDetector(
              onTap: () => setState(() => _selectedVehicle = vehicle),
              child: _buildVehicleCard(
                vehicle,
                _selectedVehicle?.id == vehicle.id,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMileageInput(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              localizations.currentMileage,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            if (_isLocationEnabled)
              ElevatedButton.icon(
                onPressed: () => _useAutoMileage(localizations),
                icon: const Icon(Icons.location_on, size: 16),
                label: Text(localizations.autoMileage),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _mileageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: _textColor, fontSize: 16),
          decoration: InputDecoration(
            hintText: localizations.enterCurrentMileage,
            hintStyle: const TextStyle(color: _grey400, fontSize: 14),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixText: localizations.km,
            suffixStyle: const TextStyle(
              color: _primaryColor,
              fontWeight: FontWeight.bold,
            ),
            prefixIcon: const Icon(Icons.speed, color: _secondaryColor),
          ),
        ),
        if (_isLocationEnabled && _autoMileage > 0) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _primaryColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.directions_car,
                  color: _primaryColor,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    localizations.todaysAutoMileage(
                      _autoMileage.toStringAsFixed(1),
                    ),
                    style: const TextStyle(
                      color: _primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (_selectedVehicle != null)
                  Text(
                    localizations.totalMileage(
                      _selectedVehicle!.currentMileage + _autoMileage.round(),
                    ),
                    style: const TextStyle(
                      color: _textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildServicesSwitch(AppLocalizations localizations) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          localizations.includesServices,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Switch(
          value: _hasServices,
          onChanged: (bool value) {
            setState(() {
              _hasServices = value;
              if (!value) {
                _selectedServices = _selectedServices.map(
                  (key, value) => MapEntry(key, false),
                );
              }
            });
          },
          activeThumbColor: _primaryColor,
          inactiveTrackColor: Colors.grey[600],
        ),
      ],
    );
  }

  Widget _buildServicesGrid(AppLocalizations localizations) {
    if (!_hasServices) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.servicesPerformed,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.85,
          ),
          itemCount: _availableServices.length,
          itemBuilder: (context, index) =>
              _buildServiceCard(_availableServices[index]),
        ),
      ],
    );
  }

  Widget _buildNotesInput(AppLocalizations localizations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          localizations.notesOptional,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          style: const TextStyle(color: _textColor, fontSize: 14),
          decoration: InputDecoration(
            hintText: localizations.addAdditionalNotes,
            hintStyle: const TextStyle(color: _grey400),
            border: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _secondaryColor),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: _primaryColor),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations localizations) {
    final bool canSave =
        _mileageController.text.isNotEmpty && _selectedVehicle != null;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canSave ? () => _saveRecord(localizations) : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave ? _primaryColor : _grey400,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.save, size: 20),
            const SizedBox(width: 8),
            Text(
              localizations.saveRecord,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: _textColor),
          const SizedBox(height: 16),
          Text(
            localizations.loadingServices,
            style: const TextStyle(color: _textColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String error, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            localizations.errorLoadingData,
            style: const TextStyle(color: _textColor, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(color: _grey300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehiclesWidget(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car_outlined, color: _grey400, size: 64),
          const SizedBox(height: 16),
          Text(
            localizations.noVehicleFound,
            style: const TextStyle(color: _textColor, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.addVehicleFirst,
            style: const TextStyle(color: _grey300),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
    List<Vehicle> vehicles,
    AppLocalizations localizations,
  ) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _servicesDataFuture,
      builder: (context, servicesSnapshot) {
        if (servicesSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator(localizations);
        }

        if (servicesSnapshot.hasData) {
          final servicesData = servicesSnapshot.data!;
          _availableServices = servicesData['services'] as List<Service>;
          _serviceIcons = servicesData['icons'] as Map<int, String>;
          if (_selectedServices.isEmpty) {
            _selectedServices = servicesData['selection'] as Map<int, bool>;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildVehicleSelection(vehicles),
              const SizedBox(height: 24),
              _buildMileageInput(localizations),
              const SizedBox(height: 24),
              _buildServicesSwitch(localizations),
              const SizedBox(height: 16),
              _buildServicesGrid(localizations),
              const SizedBox(height: 24),
              _buildNotesInput(localizations),
              const SizedBox(height: 24),
              _buildSaveButton(localizations),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: _textColor),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          localizations.services,
          style: const TextStyle(
            color: _textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: _vehiclesFuture,
        builder: (context, vehiclesSnapshot) {
          if (vehiclesSnapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator(localizations);
          } else if (vehiclesSnapshot.hasError) {
            return _buildErrorWidget(
              vehiclesSnapshot.error.toString(),
              localizations,
            );
          } else if (!vehiclesSnapshot.hasData ||
              vehiclesSnapshot.data!.isEmpty) {
            return _buildNoVehiclesWidget(localizations);
          }

          final vehicles = vehiclesSnapshot.data!;
          _selectedVehicle ??= vehicles.first;

          return _buildMainContent(vehicles, localizations);
        },
      ),
    );
  }
}
