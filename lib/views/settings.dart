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
  final Future<List<Vehicle>> _vehiclesFuture = DatabaseService.getVehicles();

  void _changeLanguage(BuildContext context, String languageCode) {
    Locale newLocale = Locale(languageCode);
    CarServiceApp.setLocale(context, newLocale);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await LocaleService.saveLocale(languageCode);
    });
  }

  void _toggleTheme(bool isDark) {
    CarServiceApp.setTheme(context, isDark ? ThemeMode.dark : ThemeMode.light);
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el notificador del tema usando el ThemeNotifierProvider
    final themeProvider = ThemeNotifierProvider.of(context);

    if (themeProvider == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeProvider.themeNotifier,
      builder: (context, themeMode, child) {
        // Determinar si es modo oscuro basado en themeMode
        final isDarkMode = themeMode == ThemeMode.dark;

        // Definir colores basados en el tema actual
        final backgroundColor = Colors
            .transparent; // Cambiado a transparente para heredar el gradiente del padre

        final secondaryColor = const Color(0xFF75A6B1);
        final textColor = isDarkMode ? Colors.white : Colors.black87;
        final grey300 = isDarkMode ? const Color(0xFFE0E0E0) : Colors.black54;
        final cardColor = isDarkMode
            ? Colors.black.withValues(alpha: 0.3)
            : Colors.white;
        final switchActiveColor = isDarkMode ? secondaryColor : Colors.blue;
        final dividerColor = isDarkMode ? secondaryColor : Colors.grey.shade300;
        final appBarColor = isDarkMode ? Colors.transparent : Colors.grey[100];

        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: AppBar(
            backgroundColor: appBarColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios, color: textColor),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              AppLocalizations.of(context).settings,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Container(
            // Asegurar que el fondo cubra toda el área
            color: backgroundColor,
            child: FutureBuilder<List<Vehicle>>(
              future: _vehiclesFuture,
              key: const Key('vehicles_future'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDarkMode ? Colors.white : Colors.blue,
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Error loading vehicles: ${snapshot.error}",
                      style: TextStyle(color: textColor),
                    ),
                  );
                }

                final vehicles = snapshot.data ?? [];
                const int registrationLimit = 3;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context).myVehicles,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${AppLocalizations.of(context).registeredVehicles} (${vehicles.length}/$registrationLimit):",
                        style: TextStyle(fontSize: 16, color: grey300),
                      ),

                      const SizedBox(height: 16),

                      vehicles.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  ).noVehiclesRegistered,
                                  style: TextStyle(color: grey300),
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
                                  color: cardColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(
                                      color: secondaryColor,
                                      width: 1,
                                    ),
                                  ),
                                  child: ListTile(
                                    leading: Icon(
                                      Icons.directions_car,
                                      color: textColor,
                                    ),
                                    title: Text(
                                      "${vehicle.make} ${vehicle.model}",
                                      style: TextStyle(color: textColor),
                                    ),
                                    subtitle: Text(
                                      "${AppLocalizations.of(context).mileage}: ${vehicle.currentMileage} ${AppLocalizations.of(context).km}",
                                      style: TextStyle(color: grey300),
                                    ),
                                    trailing: Icon(
                                      Icons.arrow_forward_ios,
                                      color: textColor,
                                      size: 16,
                                    ),
                                    onTap: () {},
                                  ),
                                );
                              },
                            ),

                      const SizedBox(height: 24),
                      Divider(color: dividerColor),
                      const SizedBox(height: 24),

                      Text(
                        AppLocalizations.of(context).appSettings,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: secondaryColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                color: textColor,
                              ),
                              title: Text(
                                isDarkMode ? "Modo Oscuro" : "Modo Claro",
                                style: TextStyle(color: textColor),
                              ),
                              trailing: Switch(
                                value: isDarkMode,
                                activeColor: switchActiveColor,
                                onChanged: (bool value) {
                                  _toggleTheme(value);
                                },
                              ),
                            ),
                            Divider(color: dividerColor, height: 1),
                            ListTile(
                              leading: Icon(
                                Icons.notifications,
                                color: textColor,
                              ),
                              title: Text(
                                AppLocalizations.of(context).notifications,
                                style: TextStyle(color: textColor),
                              ),
                              trailing: Switch(
                                value: true,
                                activeColor: switchActiveColor,
                                onChanged: (bool value) {},
                              ),
                            ),
                            Divider(color: dividerColor, height: 1),
                            ListTile(
                              leading: Icon(Icons.language, color: textColor),
                              title: Text(
                                AppLocalizations.of(context).language,
                                style: TextStyle(color: textColor),
                              ),
                              trailing: DropdownButton<String>(
                                value: Localizations.localeOf(
                                  context,
                                ).languageCode,
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: textColor,
                                ),
                                dropdownColor: isDarkMode
                                    ? const Color(0xFF10162A)
                                    : Colors.white,
                                underline: Container(),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    _changeLanguage(context, newValue);
                                  }
                                },
                                items: <String>['en', 'es']
                                    .map<DropdownMenuItem<String>>((
                                      String value,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(
                                          value == 'en'
                                              ? AppLocalizations.of(
                                                  context,
                                                ).english
                                              : AppLocalizations.of(
                                                  context,
                                                ).spanish,
                                          style: TextStyle(color: textColor),
                                        ),
                                      );
                                    })
                                    .toList(),
                              ),
                            ),
                            Divider(color: dividerColor, height: 1),
                            ListTile(
                              leading: Icon(Icons.lock, color: textColor),
                              title: Text(
                                AppLocalizations.of(context).changePassword,
                                style: TextStyle(color: textColor),
                              ),
                              trailing: Icon(
                                Icons.arrow_forward_ios,
                                color: textColor,
                                size: 16,
                              ),
                              onTap: () {},
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      Divider(color: dividerColor),
                      const SizedBox(height: 24),

                      Text(
                        AppLocalizations.of(context).appInformation,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),

                      Card(
                        color: cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: secondaryColor, width: 1),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                AppLocalizations.of(context).version,
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                "1.0.0",
                                style: TextStyle(color: grey300),
                              ),
                            ),
                            Divider(color: dividerColor, height: 1),
                            ListTile(
                              title: Text(
                                AppLocalizations.of(context).developer,
                                style: TextStyle(color: textColor),
                              ),
                              subtitle: Text(
                                "Car Service Team",
                                style: TextStyle(color: grey300),
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
          ),
        );
      },
    );
  }
}
