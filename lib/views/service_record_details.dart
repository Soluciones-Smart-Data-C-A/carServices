import 'package:flutter/material.dart';
import 'package:car_service_app/services/app_localizations.dart';
import 'package:car_service_app/utils/icon_helper.dart';

// Convertimos a StatefulWidget para poder manejar las variables de color en la clase State
// y mantener el método build más limpio, tal como solicitaste.
class ServiceRecordDetailsView extends StatefulWidget {
  final Map<String, dynamic> record;

  const ServiceRecordDetailsView({super.key, required this.record});

  @override
  State<ServiceRecordDetailsView> createState() =>
      _ServiceRecordDetailsViewState();
}

class _ServiceRecordDetailsViewState extends State<ServiceRecordDetailsView> {
  // Definimos las variables de color aquí en el State.
  // 'late' significa que se inicializarán más tarde (en el método _updateThemeColors).
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _backgroundColor1;
  late Color _backgroundColor2;
  late Color _textColor;
  late Color _cardColor;
  late Color _borderColor;
  late bool
  _isDarkMode; // También guardamos el estado del modo oscuro para usarlo en otros lados

  // Método para inicializar/actualizar los colores según el tema actual.
  // Al extraer esto a un método, limpiamos el código dentro de 'build'.
  void _updateThemeColors(BuildContext context) {
    _isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _primaryColor = const Color(0xFF2AEFDA);
    _secondaryColor = const Color(0xFF75A6B1);

    // Configuramos los colores de fondo para el gradiente
    _backgroundColor1 = _isDarkMode
        ? const Color(0xFF07303D)
        : Colors.grey[100]!;
    _backgroundColor2 = _isDarkMode
        ? const Color(0xFF040D0F)
        : Colors.grey[300]!;

    _textColor = _isDarkMode ? Colors.white : Colors.black87;

    _cardColor = _isDarkMode
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white;

    _borderColor = _isDarkMode ? Colors.white10 : Colors.grey.shade300;
  }

  // Método auxiliar para formatear la fecha
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    // 1. Llamamos a _updateThemeColors al inicio de build para asegurar que los colores estén actualizados.
    _updateThemeColors(context);

    // Obtenemos localizaciones
    final localizations = AppLocalizations.of(context);

    // Extraemos los datos del registro (accediendo a widget.record ya que estamos en la clase State)
    final record = widget.record;
    final serviceName =
        record['serviceName'] as String? ?? localizations.service;
    final vehicleMake = record['vehicleMake'] as String? ?? '';
    final vehicleModel = record['vehicleModel'] as String? ?? '';
    final mileage = record['mileage'] as int? ?? 0;
    final date = DateTime.parse(record['date'] as String);
    final notes = record['notes'] as String?;
    final iconName = record['serviceIcon'] as String? ?? 'oil_change';

    // 2. Usamos las variables de clase (_backgroundColor1, etc) en lugar de definirlas localmente.
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_backgroundColor1, _backgroundColor2],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: _textColor),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            localizations.serviceDetails,
            style: TextStyle(color: _textColor, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Tarjeta Principal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: _secondaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _secondaryColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        getIconData(iconName),
                        color: _primaryColor,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      serviceName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _textColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDarkMode
                            ? Colors.grey[400]
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Tarjeta de Detalles
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: _cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderColor),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      icon: Icons.directions_car,
                      label: localizations.vehicle,
                      value: '$vehicleMake $vehicleModel',
                    ),
                    _buildDetailRow(
                      icon: Icons.speed,
                      label: localizations.mileage,
                      value: '$mileage ${localizations.km}',
                    ),
                    if (notes != null && notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.note, color: _secondaryColor, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations.notes,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  notes,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _textColor,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hemos simplificado los argumentos de este método ya que ahora
  // puede acceder a los colores directamente de la clase State.
  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    final subtitleColor = _isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: _secondaryColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: _textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
