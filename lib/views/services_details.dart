// services_details.dart (corregido)
import 'package:flutter/material.dart';
import 'package:car_service_app/utils/index.dart';
import 'package:car_service_app/services/app_localizations.dart';

class Servicesdetails extends StatelessWidget {
  final Map<String, dynamic> serviceDetails;
  final VoidCallback onNavigateToServices;
  final VoidCallback onNavigateToHistory;
  final VoidCallback onNavigateToSettings;

  const Servicesdetails({
    super.key,
    required this.serviceDetails,
    required this.onNavigateToServices,
    required this.onNavigateToHistory,
    required this.onNavigateToSettings,
  });

  // Constants
  static const _primaryColor = Color(0xFF2AEFDA);
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _textColor = Colors.white;

  Widget _buildServiceInfoCard(
    String title,
    String value,
    String subtitle, {
    Color? valueColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const RadialGradient(
            center: Alignment.center,
            radius: 2.5,
            colors: [
              Color.fromARGB(255, 13, 20, 27),
              Color.fromARGB(255, 36, 55, 77),
              Color.fromARGB(255, 111, 136, 160),
              Color.fromARGB(255, 255, 255, 255),
            ],
            stops: [0.1, 0.3, 0.7, 1.0],
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
                  fontSize: 10,
                  color: Colors.grey[300],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: valueColor ?? _textColor,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Replica de _buildServiceInfoSection adaptada para services_details
  Widget _buildServiceInfoSection(AppLocalizations localizations) {
    final bool isDue = serviceDetails['isDue'] == true;
    final statusColor = isDue ? Colors.red.shade200 : Colors.yellow.shade200;
    final statusText = isDue ? localizations.dueSoon : localizations.pending;

    return Row(
      children: [
        _buildServiceInfoCard(
          localizations.nextService,
          "${MapUtils.getInt(serviceDetails, 'kmToNextService')}",
          localizations.km,
        ),
        const SizedBox(width: 8),
        _buildServiceInfoCard(
          localizations.remaining,
          "${MapUtils.getInt(serviceDetails, 'timeRemaining')}",
          MapUtils.getString(serviceDetails, 'timeUnit'),
        ),
        const SizedBox(width: 8),
        _buildServiceInfoCard(
          localizations.status,
          statusText,
          "",
          valueColor: statusColor,
        ),
      ],
    );
  }

  Widget _buildVehicleImageWithProgress() {
    final int percentage = MapUtils.getInt(
      serviceDetails,
      'percentageRemaining',
    );
    final double imageHeight = 400;
    final double gradientTop = (1.0 - (percentage / 100)) * imageHeight;

    // Determinar color basado en el porcentaje
    Color getProgressColor() {
      if (percentage >= 80) {
        return Colors.red.shade400; // Rojo para 80-100% (urgente)
      } else if (percentage >= 50) {
        return Colors.orange.shade400; // Naranja para 50-79% (intermedio)
      } else {
        return Colors.green.shade400; // Verde para 0-49% (bajo)
      }
    }

    final progressColor = getProgressColor();

    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            'assets/images/chery_arauca.png',
            fit: BoxFit.contain,
            height: imageHeight,
          ),
        ),
        Positioned(
          top: gradientTop,
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  progressColor,
                  progressColor.withValues(alpha: 0.7),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.1, 0.5],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Text(
              "$percentage%",
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: progressColor, // Mismo color que el gradiente
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          MapUtils.getString(
            serviceDetails,
            'service',
            defaultValue: localizations.serviceDetails,
          ),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildVehicleImageWithProgress(),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.serviceInformation,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),
                _buildServiceInfoSection(localizations),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // ============ NAVIGATION ============
  // ============ NAVIGATION ============
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF10162A),
      selectedItemColor: _primaryColor,
      unselectedItemColor: Colors.white54,
      showUnselectedLabels: true,
      currentIndex: 0,
      onTap: (index) {
        _handleNavigation(context, index);
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: AppLocalizations.of(context).home,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_outlined),
          label: AppLocalizations.of(context).services,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.history_outlined),
          label: AppLocalizations.of(context).history,
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings_outlined),
          label: AppLocalizations.of(context).settings,
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pop(context);
      return;
    }

    // Ejecutar navegación primero
    switch (index) {
      case 1:
        onNavigateToServices();
        break;
      case 2:
        onNavigateToHistory();
        break;
      case 3:
        onNavigateToSettings();
        break;
    }

    // Luego cerrar después de un microtask, verificando mounted
    Future.microtask(() {
      if (context.mounted) {
        Navigator.pop(context);
      }
    });
  }
}
