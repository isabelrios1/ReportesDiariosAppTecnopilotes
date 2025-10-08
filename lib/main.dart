import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'backend/api/supabase_service.dart';
import 'backend/schema/structs/catalogo/maquina.dart';
import 'backend/schema/structs/catalogo/obras.dart';
import 'backend/schema/structs/catalogo/repuestos.dart';
import 'backend/schema/structs/catalogo/servicio.dart';
import 'flutter_flow/flutter_flow_util.dart';
// ↓ AÑADE ESTAS IMPORTACIONES
import 'backend/api/supabase_manager.dart';
import 'backend/api/repositories/catalogo_repo.dart';
import 'backend/api/services/catalogo_service.dart';
import 'backend/api/repositories/reportes_repo.dart';
import 'backend/api/services/reporte_service.dart';
import 'backend/schema/structs/catalogo/descripcion_trabajo.dart';
import 'package:cupertino_time_picker_hiuzb7/app_state.dart'

as cupertino_time_picker_hiuzb7_app_state;

// ↓ AÑADE ESTA FUNCIÓN DE PRUEBA
Future<void> probarCreacionReporteCombustible() async {
  debugPrint('🧪 Probando CREACIÓN de Reporte Combustible...');

  try {
    // ✅ INICIALIZAR SUPABASE
    debugPrint('1. 🚀 Inicializando Supabase...');
    final supabase = SupabaseManager();
    await supabase.ensureConnected();
    debugPrint('✅ Conexión establecida');

    // 🔍 BUSCAR MÁQUINAS EXISTENTES (por CÓDIGO)
    debugPrint('2. 🔍 Buscando máquinas existentes...');
    final maquinasExistentes = await supabase.client
        .from('maquinaria')
        .select('codigo, nombre, obraActual')
        .limit(5);

    String maquinaCodigoParaPrueba;
    String maquinaNombreParaPrueba;

    if (maquinasExistentes.isEmpty) {
      debugPrint('⚠️ No hay máquinas en la base de datos');
      debugPrint('🏗️ Creando obra y máquina temporal para prueba...');

      final maquinaTemporal = await _crearObraYMaquinaTemporal(supabase);
      maquinaCodigoParaPrueba = maquinaTemporal['codigo']!;
      maquinaNombreParaPrueba = maquinaTemporal['nombre']!;
      debugPrint('✅ Obra y máquina temporal creadas: $maquinaNombreParaPrueba ($maquinaCodigoParaPrueba)');
    } else {
      // Usar la primera máquina que exista (por CÓDIGO)
      maquinaCodigoParaPrueba = maquinasExistentes.first['codigo'] as String;
      maquinaNombreParaPrueba = maquinasExistentes.first['nombre'] as String;
      final obraActual = maquinasExistentes.first['obraActual'];
      debugPrint('✅ Usando máquina existente: $maquinaNombreParaPrueba ($maquinaCodigoParaPrueba)');
      debugPrint('   - Obra asignada: $obraActual');
    }

    final reporteRepo = ReporteRepository(supabase);
    final reporteService = ReporteService(reporteRepo);

    // ========== CREAR REPORTE ==========
    debugPrint('3. ⛽ Creando reporte de combustible...');

    await reporteService.crearReporteCombustible(
      maquina: maquinaCodigoParaPrueba, // ← Usar el CÓDIGO
      litros: 75.5,
      costo: 325.75,
      tipoCombustible: 'Diesel PRUEBA',
    );

    debugPrint('✅ ✅ ✅ REPORTE CREADO EXITOSAMENTE!');
    debugPrint('   - Máquina (código): $maquinaCodigoParaPrueba');
    debugPrint('   - Máquina (nombre): $maquinaNombreParaPrueba');
    debugPrint('   - Litros: 75.5 L');
    debugPrint('   - Costo: \$325.75');
    debugPrint('   - Tipo: Diesel PRUEBA');

    // ✅ VERIFICACIÓN
    debugPrint('4. 🔍 Verificando reporte creado...');
    await Future.delayed(Duration(seconds: 1));

    final reporteCreado = await supabase.client
        .from('cambioCombustible')
        .select('nro, maquina, litros, costo, fecha')
        .eq('maquina', maquinaCodigoParaPrueba)
        .eq('tipo_combustible', 'Diesel PRUEBA')
        .order('fecha', ascending: false)
        .limit(1)
        .single();

    debugPrint('📊 Reporte verificado en BD:');
    debugPrint('   - Nro asignado: ${reporteCreado['nro']}');
    debugPrint('   - Máquina registrada: ${reporteCreado['maquina']}');
    debugPrint('   - Litros: ${reporteCreado['litros']}L');
    debugPrint('   - Costo: \$${reporteCreado['costo']}');

    debugPrint('🎉 ¡PRUEBA EXITOSA! El flujo de reportes funciona correctamente');

  } catch (e) {
    debugPrint('❌ ERROR en prueba: $e');
    debugPrint('💡 Detalles del error: ${e.toString()}');
  } finally {
    // ========== CLEANUP ==========
    debugPrint('5. 🧹 Limpiando datos de prueba...');
    await _limpiarDatosPrueba();
  }
}

// 🏗️ MÉTODO PARA CREAR OBRA Y MÁQUINA TEMPORAL
Future<Map<String, String>> _crearObraYMaquinaTemporal(SupabaseManager supabase) async {
  try {
    // 1. PRIMERO CREAR UNA OBRA TEMPORAL
    debugPrint('   🏗️ Creando obra temporal...');
    final obraTemporal = {
      'nombre': 'Obra Temporal Prueba',
    };

    final obraResponse = await supabase.client
        .from('obras')
        .insert(obraTemporal)
        .select('id')
        .single();

    final obraId = obraResponse['id'] as int;
    debugPrint('   ✅ Obra temporal creada con ID: $obraId');

    // 2. LUEGO CREAR LA MÁQUINA TEMPORAL CON LA OBRA ASIGNADA
    debugPrint('   🚜 Creando máquina temporal...');
    const codigoMaquina = 'TEMP-PRUEBA-001';
    const nombreMaquina = 'Excavadora Temporal Prueba';

    final maquinaTemporal = {
      'codigo': codigoMaquina,
      'nombre': nombreMaquina,
      'kilometraje': 1000.0,
      'horometro': 500.0,
      'tipo': 'Excavadora',
      'propietario': 'Empresa Prueba',
      'combustible': 'Diesel',
      'estado': 'operativa',
      'obraActual': obraId, // ← ASIGNAR LA OBRA CREADA
      'tipoCambio': 1.0,
    };

    await supabase.client
        .from('maquinaria')
        .insert(maquinaTemporal);

    debugPrint('   ✅ Máquina temporal creada con obra asignada');
    return {
      'codigo': codigoMaquina,
      'nombre': nombreMaquina,
    };

  } catch (e) {
    debugPrint('❌ Error creando obra y máquina temporal: $e');

    // Fallback: buscar cualquier máquina existente que YA TENGA OBRA
    try {
      final maquinasConObra = await supabase.client
          .from('maquinaria')
          .select('codigo, nombre, obraActual')
          .not('obraActual', 'is', null)
          .limit(1);

      if (maquinasConObra.isNotEmpty) {
        final codigo = maquinasConObra.first['codigo'] as String;
        final nombre = maquinasConObra.first['nombre'] as String;
        final obraActual = maquinasConObra.first['obraActual'];
        debugPrint('✅ Encontrada máquina con obra: $nombre ($codigo) - Obra: $obraActual');
        return {
          'codigo': codigo,
          'nombre': nombre,
        };
      }
    } catch (e2) {
      debugPrint('❌ Error buscando máquinas con obra: $e2');
    }

    // Último fallback extremo - intentar con máquina sin obra (si la constraint lo permite)
    try {
      final maquinasCualquiera = await supabase.client
          .from('maquinaria')
          .select('codigo, nombre')
          .limit(1);

      if (maquinasCualquiera.isNotEmpty) {
        final codigo = maquinasCualquiera.first['codigo'] as String;
        final nombre = maquinasCualquiera.first['nombre'] as String;
        debugPrint('⚠️ Usando máquina existente (puede fallar): $nombre ($codigo)');
        return {
          'codigo': codigo,
          'nombre': nombre,
        };
      }
    } catch (e3) {
      debugPrint('❌ Error en fallback extremo: $e3');
    }

    throw Exception('No se pudo crear o encontrar una máquina válida con obra asignada');
  }
}

// 🧹 MÉTODO DE LIMPIEZA MEJORADO
Future<void> _limpiarDatosPrueba() async {
  try {
    final supabase = SupabaseManager();
    await supabase.ensureConnected();

    // 1. Limpiar reportes de prueba
    final reportesEliminados = await supabase.client
        .from('cambioCombustible')
        .delete()
        .eq('tipo_combustible', 'Diesel PRUEBA');

    debugPrint('✅ Reportes de prueba limpiados: ${reportesEliminados.length} eliminados');

    // 2. Limpiar máquina temporal (si existe)
    try {
      await supabase.client
          .from('maquinaria')
          .delete()
          .eq('codigo', 'TEMP-PRUEBA-001');
      debugPrint('✅ Máquina temporal limpiada');
    } catch (e) {
      debugPrint('ℹ️ Máquina temporal no existía');
    }

    // 3. Limpiar obra temporal (si existe)
    try {
      await supabase.client
          .from('obras')
          .delete()
          .eq('nombre', 'Obra Temporal Prueba');
      debugPrint('✅ Obra temporal limpiada');
    } catch (e) {
      debugPrint('ℹ️ Obra temporal no existía');
    }

  } catch (e) {
    debugPrint('⚠️ Error en limpieza (puede ignorarse): $e');
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
    await probarCreacionReporteCombustible();

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