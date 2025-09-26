import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'backend/api/supabase_service.dart';
import 'backend/schema/structs/catalogo/empleado.dart';
import 'backend/schema/structs/catalogo/maquina.dart';
import 'backend/schema/structs/catalogo/obras.dart';
import 'backend/schema/structs/catalogo/repuestos.dart';
import 'backend/schema/structs/catalogo/servicio.dart';
import 'flutter_flow/flutter_flow_util.dart';
// ↓ AÑADE ESTAS IMPORTACIONES
import 'backend/api/supabase_manager.dart';
import 'backend/api/repositories/catalogo_repo.dart';
import 'backend/api/services/catalogo_service.dart';
import 'backend/schema/structs/catalogo/descripcion_trabajo.dart';

import 'package:cupertino_time_picker_hiuzb7/app_state.dart'
as cupertino_time_picker_hiuzb7_app_state;

// ↓ AÑADE ESTA FUNCIÓN DE PRUEBA
Future<void> probarCRUDMaquinasOptimizado() async {
  debugPrint('🧪 Probando CRUD OPTIMIZADO de Máquinas...');

  try {
    // ✅ INICIALIZAR SUPABASE
    if (!SupabaseService.isInitialized) {
      debugPrint('1. 🚀 Inicializando Supabase...');
      await SupabaseService.initialize();
    }

    final supabase = SupabaseManager();
    await supabase.ensureConnected();
    debugPrint('✅ Conexión establecida');

    final catalogoRepo = CatalogoRepository(supabase);
    final maquinaService = CatalogoService(catalogoRepo);

    // 🏗️ OBTENER O EXISTENTE O CREAR UNA OBRA
    debugPrint('2. 🔍 Buscando obra existente...');
    int? obraPruebaId = await _usarObraExistente(supabase);

    // Si no hay obras existentes, crear una mínima
    if (obraPruebaId == null) {
      debugPrint('3. 🏗️ Creando obra mínima de prueba...');
      obraPruebaId = await _crearObraMinima(supabase);
    }

    if (obraPruebaId == null) {
      debugPrint('❌ No se pudo obtener o crear obra - probando sin obra...');
      // Continuar prueba sin obra asignada
      obraPruebaId = null;
    } else {
      debugPrint('✅ Usando obra con ID: $obraPruebaId');
    }

    // 🔄 LIMPIAR DATOS DE PRUEBA PREVIOS
    debugPrint('4. 🧹 Limpiando datos de prueba previos...');
    try {
      await supabase.client
          .from('maquinaria')
          .delete()
          .eq('codigo', 'TEST-MAQ-001');
      debugPrint('✅ Datos previos limpiados');
    } catch (e) {
      debugPrint('⚠️ No se pudieron limpiar datos previos: $e');
    }

    // Datos de prueba (puede ser con o sin obra)
    final testMaquina = Maquina(
      codigo: 'TEST-MAQ-001',
      nombre: 'Máquina de Prueba CRUD',
      kilometraje: 1000.5,
      horometro: 500.75,
      tipo: 'Excavadora',
      propietario: 'Tecnopilotes',
      combustible: 'Diesel',
      estado: 'operativa',
      obraActualId: obraPruebaId, // Puede ser null
      tipoCambio: 7.85,
    );

    // ========== CREATE ==========
    debugPrint('5. 📝 Probando CREATE...');
    try {
      final insertResponse = await supabase.client
          .from('maquinaria')
          .insert(testMaquina.toJson())
          .select();

      debugPrint('✅ INSERT exitoso: ${insertResponse.length} máquinas insertadas');

      // Continuar con el resto de las pruebas...
      final maquinaEncontrada = await maquinaService.getMaquinaPorCodigo('TEST-MAQ-001');
      if (maquinaEncontrada != null) {
        debugPrint('✅ READ exitoso: ${maquinaEncontrada.nombre}');
        debugPrint('   - Obra asignada: ${maquinaEncontrada.obraActualId ?? "Ninguna"}');
      }

      // Probar actualizaciones básicas
      await maquinaService.actualizarKilometraje('TEST-MAQ-001', 1100.0);
      debugPrint('✅ Actualización de kilometraje exitosa');

      debugPrint('🎉 ¡PRUEBA COMPLETADA EXITOSAMENTE!');

    } catch (e) {
      debugPrint('❌ ERROR en operación: $e');
    }

  } catch (e) {
    debugPrint('❌ ERROR GENERAL: $e');
  } finally {
    // Limpieza...
    debugPrint('6. 🧹 Limpiando datos de prueba...');
    try {
      final supabase = SupabaseManager();
      await supabase.ensureConnected();

      await supabase.client
          .from('maquinaria')
          .delete()
          .eq('codigo', 'TEST-MAQ-001');

      debugPrint('✅ Datos de prueba limpiados');
    } catch (e) {
      debugPrint('⚠️ Error limpiando datos: $e');
    }
  }
}

// 🔨 MÉTODO PARA CREAR OBRA MÍNIMA (solo campo nombre)
Future<int?> _crearObraMinima(SupabaseManager supabase) async {
  try {
    final response = await supabase.client
        .from('obras')
        .insert({
      'nombre': 'Obra de Prueba CRUD', // Solo campo que debe existir
    })
        .select('id')
        .single();

    return response['id'] as int;
  } catch (e) {
    debugPrint('❌ Error creando obra mínima: $e');
    return null;
  }
}

Future<int?> _usarObraExistente(SupabaseManager supabase) async {
  try {
    // Buscar cualquier obra existente
    final obrasExistentes = await supabase.client
        .from('obras')
        .select('id, nombre')
        .limit(1);

    if (obrasExistentes.isNotEmpty) {
      final obraId = obrasExistentes.first['id'] as int;
      final obraNombre = obrasExistentes.first['nombre'] as String;
      debugPrint('✅ Usando obra existente: $obraNombre (ID: $obraId)');
      return obraId;
    }

    debugPrint('❌ No hay obras existentes en la base de datos');
    return null;
  } catch (e) {
    debugPrint('❌ Error buscando obra existente: $e');
    return null;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoRouter.optionURLReflectsImperativeAPIs = true;
  usePathUrlStrategy();

  try {
    // ✅ PRIMERO INICIALIZAR SUPABASE (ESTO ES LO MÁS IMPORTANTE)
    debugPrint('🚀 Inicializando Supabase desde main...');
    await SupabaseService.initialize(); // o await Supabase.initialize(...)
    debugPrint('✅ Supabase inicializado correctamente en main');

    // ↓ AHORA SÍ EJECUTAR LAS PRUEBAS
    await probarCRUDMaquinasOptimizado();

  } catch (e) {
    debugPrint('❌ ERROR CRÍTICO en inicialización: $e');
    // Decide si quieres continuar o no con la app
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