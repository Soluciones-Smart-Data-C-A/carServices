import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// Importa tus vistas
import 'package:car_service_app/views/dashboard.dart';
import 'package:car_service_app/views/services.dart';
import 'package:car_service_app/views/settings.dart';
import 'package:car_service_app/views/history.dart';

// Importa los archivos de modelos y servicio de base de datos
import 'package:car_service_app/models/vehicle.dart';
import 'package:car_service_app/services/database_service.dart';
import 'package:car_service_app/services/locale_service.dart';
import 'package:car_service_app/services/location_service.dart';
import 'package:car_service_app/services/app_localizations.dart';
import 'package:car_service_app/services/registration_service.dart';

// Importa las pantallas de registro
import 'package:car_service_app/views/signup/splash_screen.dart';
import 'package:car_service_app/views/signup/registration_step1.dart';
import 'package:car_service_app/views/signup/registration_step2.dart';
import 'package:car_service_app/views/signup/registration_step3.dart';
import 'package:car_service_app/views/signup/registration_step4.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ejecuta las inicializaciones de forma asíncrona
  await Future.wait([
    DatabaseService.initializeDb(),
    LocationService.initialize(),
  ]);

  runApp(CarServiceApp());
}

// Clase para exponer el notificador del tema
class ThemeNotifierProvider extends InheritedWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const ThemeNotifierProvider({
    super.key,
    required this.themeNotifier,
    required super.child,
  });

  static ThemeNotifierProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ThemeNotifierProvider>();
  }

  @override
  bool updateShouldNotify(ThemeNotifierProvider oldWidget) {
    return themeNotifier != oldWidget.themeNotifier;
  }
}

class CarServiceApp extends StatefulWidget {
  const CarServiceApp({super.key});

  @override
  State<CarServiceApp> createState() => CarServiceAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    CarServiceAppState? state = context
        .findAncestorStateOfType<CarServiceAppState>();
    state?.setLocale(newLocale);
  }

  static void setTheme(BuildContext context, ThemeMode newThemeMode) {
    CarServiceAppState? state = context
        .findAncestorStateOfType<CarServiceAppState>();
    state?.setTheme(newThemeMode);
  }

  static ThemeMode? getThemeMode(BuildContext context) {
    final state = context.findAncestorStateOfType<CarServiceAppState>();
    return state?._themeMode;
  }
}

class CarServiceAppState extends State<CarServiceApp> {
  Locale? _locale;
  ThemeMode _themeMode = ThemeMode.dark;
  bool _isRegistrationCompleted = false;
  bool _isLoading = true;

  // ValueNotifier para notificar cambios del tema
  final ValueNotifier<ThemeMode> _themeNotifier = ValueNotifier<ThemeMode>(
    ThemeMode.dark,
  );

  // Getter público para el notificador
  ValueNotifier<ThemeMode> get themeNotifier => _themeNotifier;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _themeNotifier.value = _themeMode; // Inicializar el notificador
    _initializeApp();
  }

  void setTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
      _themeNotifier.value = themeMode; // Actualizar el notificador
    });
  }

  // Método para inicializar la app
  void _initializeApp() async {
    // Cargar configuración en paralelo
    await Future.wait([_loadSavedLocale(), _checkRegistrationStatus()]);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadSavedLocale() async {
    final savedLocale = await LocaleService.getLocale();
    if (savedLocale != null) {
      setState(() {
        _locale = Locale(savedLocale);
      });
    }
  }

  Future<void> _checkRegistrationStatus() async {
    final isCompleted = await RegistrationService.isRegistrationCompleted();
    setState(() {
      _isRegistrationCompleted = isCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ThemeNotifierProvider(
      themeNotifier: _themeNotifier,
      child: MaterialApp(
        title: 'Car Service App',
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.grey[100],
            elevation: 0,
          ),
          colorScheme: ColorScheme.light(
            primary: const Color(0xFF2AEFDA),
            secondary: const Color(0xFF75A6B1),
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0A0F1F),
          canvasColor: const Color(0xFF10162A),
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF2AEFDA),
            secondary: const Color(0xFF75A6B1),
          ),
        ),
        locale: _locale,
        themeMode: _themeMode,
        supportedLocales: const [Locale('en', ''), Locale('es', '')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        // Lógica condicional para home
        home: _isLoading
            ? _buildLoadingScreen()
            : _isRegistrationCompleted
            ? const MainScreen()
            : const SplashScreen(),
        routes: {
          '/main': (context) => const MainScreen(),
          '/registration/step1': (context) => const RegistrationStep1(),
          '/registration/step2': (context) => const RegistrationStep2(),
          '/registration/step3': (context) =>
              RegistrationStep3(vehicleType: 'sedan', usageType: 'personal'),
          '/registration/step4': (context) =>
              const RegistrationStep4(email: '', phone: '', otpCode: ''),
        },
      ),
    );
  }

  // Pantalla de carga inicial
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late Future<List<Vehicle>> _vehiclesFuture;
  double _todayDistance = 0.0;
  bool _locationEnabled = false;
  late LocationService _locationService;

  // Variables para manejar datos de servicio pendientes
  int? _pendingServiceId;
  String? _pendingServiceName;

  @override
  void initState() {
    super.initState();
    _locationService = LocationService();
    _vehiclesFuture = DatabaseService.getVehicles();
    _initializeLocation();
  }

  void _initializeLocation() async {
    _locationEnabled = await _locationService.checkLocationPermission();

    if (_locationEnabled) {
      // Iniciar seguimiento de ubicación
      await _locationService.startLocationTracking();

      // Escuchar actualizaciones de distancia
      _locationService.distanceStream.listen((distance) {
        if (mounted) {
          setState(() {
            _todayDistance = distance;
          });
        }
      });
    }
  }

  // Función para navegar a servicios con ID y nombre
  void _navigateToServicesWithData(String name, int id) {
    setState(() {
      _pendingServiceId = id;
      _pendingServiceName = name;
      _selectedIndex = 1; // Cambiar a la pestaña de Servicios (índice 1)
    });
  }

  List<Widget> get _widgetOptions {
    return <Widget>[
      DashboardView(
        onNavigateToServices: () => _onItemTapped(1),
        onNavigateToHistory: () => _onItemTapped(2),
        onNavigateToSettings: () => _onItemTapped(3),
        onNavigateToServicesWithData: _navigateToServicesWithData,
        todayDistance: _todayDistance,
        locationEnabled: _locationEnabled,
      ),
      ServicesView(
        serviceId: _pendingServiceId,
        serviceName: _pendingServiceName,
      ),
      const HistoryView(),
      const SettingsView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      // Limpiar datos pendientes si se navega manualmente a otra pestaña
      if (index != 1) {
        _pendingServiceId = null;
        _pendingServiceName = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Vehicle>>(
      future: _vehiclesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingScreen();
        } else if (snapshot.hasError) {
          return _buildErrorScreen(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoVehiclesScreen();
        } else {
          return _buildMainScaffold();
        }
      },
    );
  }

  Widget _buildLoadingScreen() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF07303D), const Color(0xFF040D0F)]
                : [Colors.grey[100]!, Colors.grey[300]!],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              isDarkMode ? Colors.white : Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF07303D), const Color(0xFF040D0F)]
                : [Colors.grey[100]!, Colors.grey[300]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).errorLoadingData,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoVehiclesScreen() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDarkMode
                ? [const Color(0xFF07303D), const Color(0xFF040D0F)]
                : [Colors.grey[100]!, Colors.grey[300]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: isDarkMode ? Colors.white54 : Colors.black54,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noVehicleFound,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).addVehicleToStart,
                style: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScaffold() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDarkMode
              ? [const Color(0xFF07303D), const Color(0xFF040D0F)]
              : [Colors.grey[100]!, Colors.grey[300]!],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDarkMode ? const Color(0xFF10162A) : Colors.white,
          selectedItemColor: isDarkMode ? const Color(0xFF2AEFDA) : Colors.blue,
          unselectedItemColor: isDarkMode ? Colors.white54 : Colors.black54,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              label: AppLocalizations.of(context).home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.add_outlined),
              label: AppLocalizations.of(context).services,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.history_outlined),
              label: AppLocalizations.of(context).history,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              label: AppLocalizations.of(context).settings,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _locationService.dispose();
    super.dispose();
  }
}
