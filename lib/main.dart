import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'backend/api/supabase_manager.dart';
import 'backend/api/supabase_service.dart';// ← IMPORT de tu SupabaseManager

import 'package:cupertino_time_picker_hiuzb7/app_state.dart'
as cupertino_time_picker_hiuzb7_app_state;

// ← FUNCIÓN DE PRUEBA CON TU SUPABASE_MANAGER
Future<void> testSupabaseConnection() async {
  debugPrint('🔌 Probando conexión con SupabaseManager...');

  try {
    final supabase = SupabaseManager();
    await supabase.ensureConnected();

    // Probamos con una consulta simple
    final response = await supabase.client
        .from('maquinaria')
        .select('*')
        .limit(1);

    debugPrint('✅ SUPABASE_MANAGER FUNCIONANDO!');
    debugPrint('📋 Response: ${response.length} registros');

  } catch (e) {
    debugPrint('❌ ERROR CON SUPABASE_MANAGER: $e');
    debugPrint('💡 Verifica:');
    debugPrint('   - Que Supabase está inicializado');
    debugPrint('   - Las credenciales en SupabaseService');
    debugPrint('   - La conexión a internet');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  try {
    // ✅ PRIMERO inicializar Supabase (esto es lo más importante)
    debugPrint('🚀 Inicializando Supabase...');
    await SupabaseService.initialize();
    debugPrint('✅ Supabase inicializado correctamente');

    // ← LUEGO probar la conexión
    await testSupabaseConnection();

  } catch (e) {
    debugPrint('❌ ERROR crítico en inicialización: $e');
    // Puedes decidir si quieres continuar o no
  }

  final appState = FFAppState(); // Initialize FFAppState
  await appState.initializePersistedState();

  final cupertino_time_picker_hiuzb7AppState =
  cupertino_time_picker_hiuzb7_app_state.FFAppState();
  await cupertino_time_picker_hiuzb7AppState.initializePersistedState();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (context) => appState,
      ),
      ChangeNotifierProvider(
        create: (context) => cupertino_time_picker_hiuzb7AppState,
      ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  late AppStateNotifier _appStateNotifier;
  late GoRouter _router;
  String getRoute([RouteMatch? routeMatch]) {
    final RouteMatch lastMatch =
        routeMatch ?? _router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList = lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : _router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() =>
      _router.routerDelegate.currentConfiguration.matches
          .map((e) => getRoute(e))
          .toList();

  @override
  void initState() {
    super.initState();
    _appStateNotifier = AppStateNotifier.instance;
    _router = createRouter(_appStateNotifier);
  }

  void setThemeMode(ThemeMode mode) => safeSetState(() {
    _themeMode = mode;
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Reportes diarios',
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', '')],
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: false,
      ),
      themeMode: _themeMode,
      routerConfig: _router,
    );
  }
}