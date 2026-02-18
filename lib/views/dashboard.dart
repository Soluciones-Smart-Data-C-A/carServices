import 'package:car_service_app/models/service_record_display.dart';
import 'package:car_service_app/services/vehicle_api_service.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/app_localizations.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/prediction_logic.dart';
import 'package:car_service_app/utils/index.dart';
import 'package:car_service_app/views/services_details.dart';

class DashboardView extends StatefulWidget {
  final VoidCallback onNavigateToServices;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToSettings;
  final Function(String, int) onNavigateToServicesWithData;
  final double todayDistance;
  final bool locationEnabled;

  const DashboardView({
    super.key,
    required this.onNavigateToServices,
    required this.onNavigateToHistory,
    required this.onNavigateToSettings,
    required this.onNavigateToServicesWithData,
    required this.todayDistance,
    required this.locationEnabled,
  });

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  // Servicios
  late final PredictionService _predictionService;
  static final Logger _logger = Logger();

  // Estado de Tabs
  int _activeTab = 0; // 0 para Próximos, 1 para Recientes

  // Futures
  late Future<List<Vehicle>> _vehiclesFuture;
  late Future<List<Map<String, dynamic>>> _predictionsFuture;
  late Future<Vehicle?> _currentVehicleFuture;
  late Future<List<Map<String, dynamic>>> _recentServicesFuture;

  // Constantes de color que se adaptarán al tema
  // CAMBIO: Eliminado 'final' para permitir reasignación
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _backgroundColor;
  late Color _textColor;
  late Color _grey300;
  late Color _cardColor;
  late Color _cardBorderColor;

  // --- ESCALA TIPOGRÁFICA OPTIMIZADA (UX) ---
  static const double _fsDisplay = 24.0; // Headlines grandes
  static const double _fsTitle = 20.0; // Títulos de secciones/tabs
  static const double _fsBody = 15.0; // Texto principal de lectura
  static const double _fsCaption = 12.0; // Información secundaria
  static const double _fsCaptionSmall = 10.0; // Información secundaria

  @override
  void initState() {
    super.initState();
    _predictionService = PredictionService();
    _loadData();
  }

  void _loadData() {
    _vehiclesFuture = VehicleApiService.getVehicles();

    _recentServicesFuture = DatabaseService.getRecentServiceRecordsWithDetails(
      limit: 5,
    );
    _currentVehicleFuture = _loadCurrentVehicle();
  }

  void _refreshData() {
    setState(_loadData);
  }

  Future<Vehicle?> _loadCurrentVehicle() async {
    try {
      final vehicles = await _vehiclesFuture;
      if (vehicles.isNotEmpty) {
        _predictionsFuture = _predictionService.predictServices(vehicles.first);
        return vehicles.first;
      }
      _logger.w('No se encontraron vehículos en la lista');
      return null;
    } catch (e) {
      _logger.e('Error loading current vehicle: $e');
      return null;
    }
  }

  // Método para actualizar colores según el tema
  void _updateThemeColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _primaryColor = const Color(0xFF2AEFDA);
    _secondaryColor = const Color(0xFF75A6B1);
    _backgroundColor = Colors.transparent;
    _textColor = isDarkMode ? Colors.white : Colors.black87;
    _grey300 = isDarkMode ? const Color(0xFFE0E0E0) : Colors.black54;
    _cardColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white;
    _cardBorderColor = isDarkMode ? Colors.white10 : Colors.grey.shade300;
  }

  @override
  Widget build(BuildContext context) {
    _updateThemeColors(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      body: FutureBuilder<Vehicle?>(
        future: _currentVehicleFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString());
          } else if (!snapshot.hasData || snapshot.data == null) {
            return _buildNoVehicleWidget();
          }

          return _buildMainContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildMainContent(Vehicle vehicle) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            _buildUserInfo(vehicle),
            const SizedBox(height: 24),
            _buildVehicleImage(vehicle),
            const SizedBox(height: 24),
            _buildServiceInfoSection(),
            const SizedBox(height: 24),
            _buildLocationCard(),
            const SizedBox(height: 24),
            _buildServiceTabsSection(),
            const SizedBox(height: 24),
            _buildQuickActions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(Vehicle vehicle) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: _grey300.withValues(alpha: 0.3),
          child: Icon(Icons.person, color: _textColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Alex Cooper",
                style: TextStyle(
                  fontSize: _fsDisplay,
                  fontWeight: FontWeight.bold,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                "${vehicle.make} ${vehicle.model}",
                style: TextStyle(fontSize: _fsCaption, color: _grey300),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _refreshData,
          icon: Icon(Icons.refresh, color: _textColor),
          tooltip: AppLocalizations.of(context).retry,
        ),
      ],
    );
  }

  Widget _buildVehicleImage(Vehicle vehicle) {
    return Image.asset(
      _getVehicleImagePath(vehicle),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Icons.directions_car, size: 150, color: _grey300);
      },
    );
  }

  String _getVehicleImagePath(Vehicle vehicle) {
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

  Widget _buildServiceInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildServiceInfoCard(
              AppLocalizations.of(context).lastService,
              "12",
              AppLocalizations.of(context).daysAgo,
            ),
            const SizedBox(width: 12),
            _buildServiceInfoCard(
              AppLocalizations.of(context).estimated,
              "353,000",
              AppLocalizations.of(context).km,
            ),
            const SizedBox(width: 12),
            _buildServiceInfoCard(
              AppLocalizations.of(context).daily,
              "15.4",
              AppLocalizations.of(context).km,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceInfoCard(
    String title,
    String value,
    String subtitle, {
    Color? valueColor,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: isDarkMode
              ? const RadialGradient(
                  center: Alignment.center,
                  radius: 2.5,
                  colors: [
                    Color.fromARGB(255, 13, 20, 27),
                    Color.fromARGB(255, 36, 55, 77),
                    Color.fromARGB(255, 111, 136, 160),
                    Color.fromARGB(255, 255, 255, 255),
                  ],
                  stops: [0.1, 0.3, 0.7, 1.0],
                )
              : RadialGradient(
                  center: Alignment.center,
                  radius: 2.5,
                  colors: [
                    Colors.grey.shade200,
                    Colors.grey.shade300,
                    Colors.grey.shade400,
                    Colors.white,
                  ],
                  stops: const [0.1, 0.3, 0.7, 1.0],
                ),
          border: Border.all(
            color: _secondaryColor.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: _fsCaptionSmall,
                  color: _grey300,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: _fsTitle,
                fontWeight: FontWeight.bold,
                color: valueColor ?? _textColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: _fsCaptionSmall,
                color: _grey300,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _cardBorderColor),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(
                  widget.locationEnabled
                      ? Icons.location_on
                      : Icons.location_off,
                  color: widget.locationEnabled ? Colors.red : Colors.orange,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.locationEnabled
                            ? '${AppLocalizations.of(context).todayDistance}: ${widget.todayDistance.toStringAsFixed(1)} ${AppLocalizations.of(context).km}'
                            : AppLocalizations.of(context).enableLocation,
                        style: TextStyle(
                          color: _textColor,
                          fontSize: _fsBody,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 100,
            margin: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/map_background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white10
                            : Colors.black12,
                        child: Icon(Icons.map_outlined, color: _grey300),
                      );
                    },
                  ),
                  Container(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.1),
                  ),
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        if (widget.locationEnabled)
                          TweenAnimationBuilder(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(seconds: 2),
                            builder: (context, double value, child) {
                              return Container(
                                width: 40 * value,
                                height: 40 * value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.red.withValues(
                                    alpha: 1.0 - value,
                                  ),
                                ),
                              );
                            },
                          ),
                        Icon(
                          Icons.my_location,
                          color: widget.locationEnabled ? Colors.red : _grey300,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTabsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTabTrigger(0, AppLocalizations.of(context).upcomingServices),
            const SizedBox(width: 24),
            _buildTabTrigger(1, AppLocalizations.of(context).recentServices),
            const Spacer(),
            if (_activeTab == 1)
              TextButton(
                onPressed: widget.onNavigateToHistory,
                child: Text(
                  AppLocalizations.of(context).viewAll,
                  style: TextStyle(color: _primaryColor, fontSize: _fsCaption),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _activeTab == 0
              ? _buildUpcomingContent()
              : _buildRecentContent(),
        ),
      ],
    );
  }

  Widget _buildTabTrigger(int index, String label) {
    final bool isActive = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: IntrinsicWidth(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: _fsTitle,
                fontWeight: FontWeight.bold,
                color: isActive ? _textColor : _grey300,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              decoration: BoxDecoration(
                color: isActive ? _primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingContent() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: const ValueKey('upcoming_future'),
      future: _predictionsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        } else if (snapshot.hasError) {
          return _buildErrorCard(AppLocalizations.of(context).errorLoadingData);
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(AppLocalizations.of(context).noServiceRecords);
        }
        return Column(children: snapshot.data!.map(_buildServiceItem).toList());
      },
    );
  }

  Widget _buildRecentContent() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      key: const ValueKey('recent_future'),
      future: _recentServicesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingCard();
        } else if (snapshot.hasError) {
          return _buildErrorCard(
            AppLocalizations.of(context).errorLoadingHistory,
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyCard(AppLocalizations.of(context).noServiceRecords);
        }

        final services = snapshot.data!
            .map((map) => ServiceRecordDisplay.fromMap(map))
            .toList();
        return Column(children: services.map(_buildServiceCard).toList());
      },
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final int percentage = service['percentageRemaining'] ?? 0;
    final bool isUrgent = service['isUrgent'] == true;

    Color getPercentageColor() {
      if (percentage >= 80) {
        return Colors.red.shade400;
      } else if (percentage >= 50) {
        return Colors.orange.shade400;
      } else {
        return Colors.green.shade400;
      }
    }

    final percentageColor = getPercentageColor();

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Servicesdetails(
                serviceDetails: service,
                onNavigateToServices: widget.onNavigateToServices,
                onNavigateToHistory: widget.onNavigateToHistory,
                onNavigateToSettings: widget.onNavigateToSettings,
                onNavigateToServicesWithData:
                    widget.onNavigateToServicesWithData,
              ),
            ),
          );
        },
        child: Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isUrgent ? Colors.red.shade400 : _cardBorderColor,
              width: isUrgent ? 2 : 1,
            ),
          ),
          color: _cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service['service'] ?? 'N/A',
                        style: TextStyle(
                          fontSize: _fsBody,
                          fontWeight: FontWeight.bold,
                          color: isUrgent ? Colors.red.shade400 : _textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context).recommendedAt} ${service['kmToNextService'] ?? 'N/A'} ${AppLocalizations.of(context).km}',
                        style: TextStyle(
                          fontSize: _fsCaption,
                          color: isUrgent ? Colors.red.shade400 : _grey300,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${AppLocalizations.of(context).approxIn} ${service['timeRemaining'] ?? 'N/A'} ${service['timeUnit'] ?? ''}',
                        style: TextStyle(
                          fontSize: _fsCaption,
                          color: isUrgent ? Colors.red.shade400 : _grey300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: _secondaryColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(
                        getIconData(service['icon'] ?? 'default'),
                        color: isUrgent ? Colors.red.shade400 : _textColor,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$percentage%',
                      style: TextStyle(
                        fontSize: _fsBody,
                        fontWeight: FontWeight.bold,
                        color: percentageColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(ServiceRecordDisplay service) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: _cardBorderColor, width: 1),
      ),
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.serviceName ?? '',
                    style: TextStyle(
                      fontSize: _fsBody,
                      fontWeight: FontWeight.bold,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.of(context).serviceAt} ${service.mileage} ${AppLocalizations.of(context).km}',
                    style: TextStyle(color: _grey300, fontSize: _fsCaption),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatDate(service.date),
                    style: TextStyle(color: _grey300, fontSize: _fsCaption),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: _secondaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Icon(
                getIconData(service.serviceName ?? ''),
                color: _textColor,
                size: 24.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context).quickActions,
          style: TextStyle(
            color: _textColor,
            fontSize: _fsTitle,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.43,
              child: _buildActionButton(
                icon: Icons.add_circle_outline,
                title: AppLocalizations.of(context).addService,
                color: _primaryColor,
                onTap: widget.onNavigateToServices,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.43,
              child: _buildActionButton(
                icon: Icons.directions_car,
                title: AppLocalizations.of(context).addVehicle,
                color: Colors.blue,
                onTap: widget.onNavigateToSettings,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.43,
              child: _buildActionButton(
                icon: Icons.history,
                title: AppLocalizations.of(context).viewHistory,
                color: Colors.orange,
                onTap: widget.onNavigateToHistory,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.43,
              child: _buildActionButton(
                icon: Icons.settings,
                title: AppLocalizations.of(context).settings,
                color: Colors.purple,
                onTap: widget.onNavigateToSettings,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      color: color.withValues(alpha: 0.1),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: _textColor,
                      fontSize: _fsCaption,
                      fontWeight: FontWeight.w500,
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

  Widget _buildLoadingIndicator() {
    return Center(child: CircularProgressIndicator(color: _primaryColor));
  }

  Widget _buildLoadingCard() {
    return Card(
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: _primaryColor),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).loadingServices,
                style: TextStyle(color: _textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Card(
      color: Colors.red.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: TextStyle(color: _textColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      color: _cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, color: _grey300, size: 48),
              const SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(color: _grey300),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            '${AppLocalizations.of(context).errorLoadingData}: $error',
            style: TextStyle(color: _textColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    );
  }

  Widget _buildNoVehicleWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car_outlined, size: 64, color: _grey300),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context).noVehicleFound,
            style: TextStyle(color: _textColor, fontSize: _fsTitle),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context).addVehicleToStart,
            style: TextStyle(color: _grey300),
          ),
        ],
      ),
    );
  }
}
