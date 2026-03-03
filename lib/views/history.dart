// history.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/utils/icon_helper.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/app_localizations.dart';
import 'package:car_service_app/views/service_record_details.dart'; // Importamos la nueva vista de detalles

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  HistoryViewState createState() => HistoryViewState();
}

class HistoryViewState extends State<HistoryView> {
  // Constantes de color que se adaptarán al tema
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _backgroundColor;
  late Color _textColor;
  late Color _grey300;
  late Color _grey400;
  late Color _cardColor;
  late Color _borderColor;
  // Eliminamos _dialogBackgroundColor ya que no usaremos diálogos

  late Future<List<Map<String, dynamic>>> _serviceRecordsFuture;

  @override
  void initState() {
    super.initState();
    _serviceRecordsFuture = DatabaseService.getServiceRecordsWithDetails();
  }

  // Método para actualizar colores según el tema
  void _updateThemeColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    _primaryColor = const Color(0xFF2AEFDA);
    _secondaryColor = const Color(0xFF75A6B1);
    _backgroundColor = Colors.transparent;
    _textColor = isDarkMode ? Colors.white : Colors.black87;
    _grey300 = isDarkMode ? const Color(0xFFE0E0E0) : Colors.black54;
    _grey400 = isDarkMode ? const Color(0xFFBDBDBD) : Colors.black45;
    _cardColor = isDarkMode
        ? Colors.black.withValues(alpha: 0.3)
        : Colors.white;
    _borderColor = isDarkMode ? Colors.white10 : Colors.grey.shade300;
    // Eliminamos la asignación de _dialogBackgroundColor
  }

  void _refreshData() {
    setState(() {
      _serviceRecordsFuture = DatabaseService.getServiceRecordsWithDetails();
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _buildServiceRecordCard(
    Map<String, dynamic> record,
    AppLocalizations localizations,
  ) {
    final serviceName =
        record['serviceName'] as String? ?? localizations.service;
    final vehicleMake = record['vehicleMake'] as String? ?? '';
    final vehicleModel = record['vehicleModel'] as String? ?? '';
    final date = DateTime.parse(record['date'] as String);
    final iconName = record['serviceIcon'] as String? ?? 'oil_change';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _borderColor, width: 1),
      ),
      color: _cardColor,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _secondaryColor.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(getIconData(iconName), color: _secondaryColor, size: 24),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              serviceName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: _textColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$vehicleMake $vehicleModel',
              style: TextStyle(color: _grey300, fontSize: 14),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: _grey400),
                  const SizedBox(width: 4),
                  Text(_formatDate(date), style: TextStyle(color: _grey300)),
                ],
              ),
            ],
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, color: _grey400, size: 16),
        onTap: () {
          // En lugar de mostrar el diálogo, navegamos a la nueva pantalla de detalles
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ServiceRecordDetailsView(record: record),
            ),
          );
        },
      ),
    );
  }

  // Eliminados métodos _showServiceDetails y _buildDetailItem ya que no se usan

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
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
            localizations.errorLoadingHistory,
            style: TextStyle(color: _textColor, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: _grey300),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshData,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, color: _grey400, size: 64),
          const SizedBox(height: 16),
          Text(
            localizations.noServiceRecords,
            style: TextStyle(
              color: _textColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.servicesWillAppearHere,
            style: TextStyle(color: _grey400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateThemeColors(context);
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: _textColor),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainScreen()),
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          localizations.serviceHistory,
          style: TextStyle(
            color: _textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _serviceRecordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingIndicator();
          } else if (snapshot.hasError) {
            return _buildErrorWidget(snapshot.error.toString(), localizations);
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState(localizations);
          }

          final records = snapshot.data!;

          // Create a mutable copy and sort by date (most recent first)
          final mutableRecords = List<Map<String, dynamic>>.from(records);
          mutableRecords.sort((a, b) {
            final dateA = DateTime.parse(a['date'] as String);
            final dateB = DateTime.parse(b['date'] as String);
            return dateB.compareTo(dateA);
          });

          final sortedRecords = mutableRecords;

          return RefreshIndicator(
            onRefresh: () async {
              _refreshData();
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: _primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: sortedRecords.length,
              itemBuilder: (context, index) {
                return _buildServiceRecordCard(
                  sortedRecords[index],
                  localizations,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
