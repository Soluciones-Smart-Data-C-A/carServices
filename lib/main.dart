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
import 'package:car_service_app/views/registration/splash_screen.dart';
import 'package:car_service_app/views/registration/registration_step1.dart';
import 'package:car_service_app/views/registration/registration_step2.dart';
import 'package:car_service_app/views/registration/registration_step3.dart';
import 'package:car_service_app/views/registration/registration_step4.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ejecuta las inicializaciones de forma asíncrona
  await Future.wait([
    DatabaseService.initializeDb(),
    LocationService.initialize(),
  ]);

  runApp(CarServiceApp());
}

class CarServiceApp extends StatefulWidget {
  const CarServiceApp({super.key});

  @override
  State<CarServiceApp> createState() => _CarServiceAppState();

  static void setLocale(BuildContext context, Locale newLocale) {
    _CarServiceAppState? state = context
        .findAncestorStateOfType<_CarServiceAppState>();
    state?.setLocale(newLocale);
  }
}

class _CarServiceAppState extends State<CarServiceApp> {
  Locale? _locale;
  bool _isRegistrationCompleted = false; // NUEVO: Estado de registro
  bool _isLoading = true; // NUEVO: Estado de carga

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _initializeApp(); // MODIFICADO: Inicialización mejorada
  }

  // NUEVO: Método para inicializar la app
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
    return MaterialApp(
      title: 'Car Service App',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Color(0xFF0A0F1F),
        canvasColor: Color(0xFF10162A),
        colorScheme: ColorScheme.dark(primary: Color(0xFF2AEFDA)),
      ),
      locale: _locale,
      supportedLocales: [Locale('en', ''), Locale('es', '')],
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // MODIFICADO: Lógica condicional para home
      home: _isLoading
          ? _buildLoadingScreen()
          : _isRegistrationCompleted
          ? MainScreen()
          : SplashScreen(),
      routes: {
        '/main': (context) => MainScreen(),
        '/registration/step1': (context) => RegistrationStep1(),
        '/registration/step2': (context) => RegistrationStep2(),
        '/registration/step3': (context) => RegistrationStep3(
          vehicleType: 'sedan', // Estos valores vendrán del paso anterior
          usageType: 'personal',
        ),
        '/registration/step4': (context) => RegistrationStep4(
          email: '', // Estos se pasarán desde el paso 3
          phone: '',
          otpCode: '',
        ),
      },
    );
  }

  // NUEVO: Pantalla de carga inicial
  Widget _buildLoadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: Center(
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

  List<Widget> get _widgetOptions {
    return <Widget>[
      DashboardView(
        onNavigateToServices: () => _onItemTapped(1),
        onNavigateToHistory: () => _onItemTapped(2),
        onNavigateToSettings: () => _onItemTapped(3),
        todayDistance: _todayDistance,
        locationEnabled: _locationEnabled,
      ),
      ServicesView(),
      HistoryView(),
      SettingsView(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
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
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 64),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).errorLoadingData,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                error,
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoVehiclesScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF07303D), Color(0xFF040D0F)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: Colors.white54,
                size: 64,
              ),
              SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).noVehicleFound,
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).addVehicleToStart,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainScaffold() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF07303D), Color(0xFF040D0F)],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: _widgetOptions[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Color(0xFF10162A),
          selectedItemColor: Color(0xFF2AEFDA),
          unselectedItemColor: Colors.white54,
          showUnselectedLabels: true,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
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
