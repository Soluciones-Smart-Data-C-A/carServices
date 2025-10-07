// settings.dart
import 'package:flutter/material.dart';
import 'package:car_service_app/main.dart';
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/app_localizations.dart';
import 'package:car_service_app/services/locale_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  static const _backgroundColor = Colors.transparent;
  static const _secondaryColor = Color(0xFF75A6B1);
  static const _textColor = Colors.white;
  static const _grey300 = Color(0xFFE0E0E0);

  void _changeLanguage(BuildContext context, String languageCode) {
    // Actualización inmediata del UI
    setState(() {});

    // Actualiza el locale inmediatamente
    Locale newLocale = Locale(languageCode);
    CarServiceApp.setLocale(context, newLocale);

    // Guardar en segundo plano sin afectar el UI
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocaleService.saveLocale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
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
          AppLocalizations.of(context).settings,
          style: TextStyle(
            color: _textColor,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Vehicle>>(
        future: DatabaseService.getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading vehicles: ${snapshot.error}",
                style: const TextStyle(color: _textColor),
              ),
            );
          }

          final vehicles = snapshot.data ?? [];
          const int registrationLimit = 3; // Vehicle limit

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle management section
                Text(
                  AppLocalizations.of(context).myVehicles,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${AppLocalizations.of(context).registeredVehicles} (${vehicles.length}/$registrationLimit):",
                  style: const TextStyle(fontSize: 16, color: _grey300),
                ),

                const SizedBox(height: 16),

                vehicles.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            AppLocalizations.of(context).noVehiclesRegistered,
                            style: const TextStyle(color: _grey300),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: vehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = vehicles[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            color: Colors.black.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: _secondaryColor,
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              leading: const Icon(
                                Icons.directions_car,
                                color: _textColor,
                              ),
                              title: Text(
                                "${vehicle.make} ${vehicle.model}",
                                style: const TextStyle(color: _textColor),
                              ),
                              subtitle: Text(
                                "${AppLocalizations.of(context).mileage}: ${vehicle.currentMileage} ${AppLocalizations.of(context).km}",
                                style: const TextStyle(color: _grey300),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                color: _textColor,
                                size: 16,
                              ),
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "View details of ${vehicle.make} ${vehicle.model}",
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                const SizedBox(height: 24),
                const Divider(color: _secondaryColor),
                const SizedBox(height: 24),

                // Application settings options
                Text(
                  AppLocalizations.of(context).appSettings,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: _secondaryColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(
                          Icons.notifications,
                          color: _textColor,
                        ),
                        title: Text(
                          AppLocalizations.of(context).notifications,
                          style: const TextStyle(color: _textColor),
                        ),
                        trailing: Switch(
                          value: true,
                          activeThumbColor: _secondaryColor,
                          onChanged: (bool value) {},
                        ),
                      ),
                      const Divider(color: _secondaryColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.language, color: _textColor),
                        title: Text(
                          AppLocalizations.of(context).language,
                          style: const TextStyle(color: _textColor),
                        ),
                        trailing: DropdownButton<String>(
                          value: Localizations.localeOf(context).languageCode,
                          icon: const Icon(
                            Icons.arrow_drop_down,
                            color: _textColor,
                          ),
                          dropdownColor: const Color(0xFF10162A),
                          underline: Container(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _changeLanguage(context, newValue);
                            }
                          },
                          items: <String>['en', 'es']
                              .map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value == 'en'
                                        ? AppLocalizations.of(context).english
                                        : AppLocalizations.of(context).spanish,
                                    style: const TextStyle(color: _textColor),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                      const Divider(color: _secondaryColor, height: 1),
                      ListTile(
                        leading: const Icon(Icons.lock, color: _textColor),
                        title: Text(
                          AppLocalizations.of(context).changePassword,
                          style: const TextStyle(color: _textColor),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: _textColor,
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                      const Divider(color: _secondaryColor, height: 1),
                      ListTile(
                        leading: Icon(Icons.logout, color: Colors.red[300]),
                        title: Text(
                          AppLocalizations.of(context).signOut,
                          style: TextStyle(color: Colors.red[300]),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.red[300],
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(color: _secondaryColor),
                const SizedBox(height: 24),

                // App information
                Text(
                  AppLocalizations.of(context).appInformation,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  color: Colors.black.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: _secondaryColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context).version,
                          style: const TextStyle(color: _textColor),
                        ),
                        subtitle: const Text(
                          "1.0.0",
                          style: TextStyle(color: _grey300),
                        ),
                      ),
                      const Divider(color: _secondaryColor, height: 1),
                      ListTile(
                        title: Text(
                          AppLocalizations.of(context).developer,
                          style: const TextStyle(color: _textColor),
                        ),
                        subtitle: const Text(
                          "Car Service Team",
                          style: TextStyle(color: _grey300),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
