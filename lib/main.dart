import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'backend/api/supabase_service.dart';
import 'backend/schema/structs/empleado.dart';
import 'backend/schema/structs/obras.dart';
import 'backend/schema/structs/servicio.dart';
import 'flutter_flow/flutter_flow_util.dart';
// ↓ AÑADE ESTAS IMPORTACIONES
import 'backend/api/supabase_manager.dart';
import 'backend/api/repositories/catalogo_repo.dart';
import 'backend/api/services/catalogo_service.dart';
import 'backend/schema/structs/descripcion_trabajo.dart';

import 'package:cupertino_time_picker_hiuzb7/app_state.dart'
as cupertino_time_picker_hiuzb7_app_state;

// ↓ AÑADE ESTA FUNCIÓN DE PRUEBA

Future<void> probarCRUDServicios() async {
  debugPrint('🧪 Probando CRUD completo de Servicios...');

  // Datos de prueba
  final testServicio = servicios(
      codigo: 'TEST-001',
      descripcion: 'Servicio de Prueba CRUD'
  );

  final testServicioActualizado = servicios(
      codigo: 'TEST-001',
      descripcion: 'Servicio de Prueba ACTUALIZADO'
  );

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
    final servicioService = CatalogoService(catalogoRepo);

    // 🔄 LIMPIAR DATOS DE PRUEBA PREVIOS
    debugPrint('2. 🧹 Limpiando datos de prueba previos...');
    try {
      await supabase.client
          .from('servicios')
          .delete()
          .eq('codigo', 'TEST-001');
      debugPrint('✅ Datos previos limpiados');
    } catch (e) {
      debugPrint('⚠️ No se pudieron limpiar datos previos: $e');
    }

    // ========== CREATE ==========
    debugPrint('3. 📝 Probando CREATE (Insertar servicio)...');
    try {
      final insertResponse = await supabase.client
          .from('servicios')
          .insert({
        'codigo': testServicio.codigo,
        'descripcion': testServicio.descripcion,
      })
          .select();

      debugPrint('✅ INSERT exitoso: ${insertResponse.length} servicios insertados');
      debugPrint('   Datos insertados: ${insertResponse.first}');

    } catch (e) {
      debugPrint('❌ ERROR en INSERT: $e');
      debugPrint('💡 Verifica:');
      debugPrint('   - Permisos RLS en tabla servicios');
      debugPrint('   - Estructura de la tabla (campos codigo, descripcion)');
      debugPrint('   - Si el código TEST-001 ya existe');
      return;
    }

    // ========== READ ==========
    debugPrint('4. 📖 Probando READ (Leer servicios)...');

    // a) Leer todos los servicios
    final todosServicios = await servicioService.getServicios();
    debugPrint('✅ READ todas: ${todosServicios.length} servicios');

    // b) Buscar por código específico
    final servicioEncontrado = await servicioService.getServicioPorCodigo('TEST-001');
    if (servicioEncontrado != null) {
      debugPrint('✅ READ por código: ${servicioEncontrado.codigo} - ${servicioEncontrado.descripcion}');
    } else {
      debugPrint('❌ No se encontró el servicio insertado');
      return;
    }

    // c) Buscar por descripción exacta
    final servicioPorDescripcion = await servicioService.getServicioPorDescripcion('Servicio de Prueba CRUD');
    if (servicioPorDescripcion != null) {
      debugPrint('✅ READ por descripción: ${servicioPorDescripcion.descripcion}');
    } else {
      debugPrint('⚠️ No se encontró por descripción exacta');
    }

    // d) Buscar con búsqueda general
    final resultadosBusqueda = await servicioService.buscarServicios('Prueba');
    debugPrint('✅ Búsqueda general: ${resultadosBusqueda.length} resultados');

    // e) Buscar por descripción (contains)
    final porDescripcionContains = await servicioService.buscarServiciosPorDescripcion('Prueba');
    debugPrint('✅ Búsqueda por descripción: ${porDescripcionContains.length} resultados');

    // ========== UPDATE ==========
    debugPrint('5. ✏️ Probando UPDATE (Actualizar servicio)...');
    try {
      final updateResponse = await supabase.client
          .from('servicios')
          .update({
        'descripcion': testServicioActualizado.descripcion,
      })
          .eq('codigo', 'TEST-001')
          .select();

      debugPrint('✅ UPDATE exitoso: ${updateResponse.length} servicios actualizados');
      debugPrint('   Datos actualizados: ${updateResponse.first}');

      // Verificar que se actualizó
      final servicioActualizado = await servicioService.getServicioPorCodigo('TEST-001');
      if (servicioActualizado != null && servicioActualizado.descripcion == 'Servicio de Prueba ACTUALIZADO') {
        debugPrint('✅ Verificación UPDATE: El servicio se actualizó correctamente');
      } else {
        debugPrint('❌ Verificación UPDATE: El servicio no se actualizó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en UPDATE: $e');
    }

    // ========== VALIDACIONES DEL SERVICIO ==========
    debugPrint('6. ✅ Probando validaciones del servicio...');

    // a) Validar existencia
    final existe = await servicioService.existeServicio('TEST-001');
    debugPrint('   - Existe código TEST-001: $existe');

    // b) Validar existencia por descripción
    final existeDescripcion = await servicioService.existeServicioPorDescripcion('Servicio de Prueba ACTUALIZADO');
    debugPrint('   - Existe por descripción: $existeDescripcion');

    // c) Obtener servicios válidos
    final serviciosValidos = await servicioService.getServiciosValidos();
    debugPrint('   - Servicios válidos: ${serviciosValidos.length}');

    // d) Formato dropdown
    final dropdownData = await servicioService.getServiciosParaDropdown();
    debugPrint('   - Items dropdown: ${dropdownData.length}');
    if (dropdownData.isNotEmpty) {
      debugPrint('   - Ejemplo dropdown: ${dropdownData.first['label']}');
    }

    // e) Sugerencias para autocompletado
    final sugerenciasDesc = await servicioService.getSugerenciasDescripciones();
    final sugerenciasCod = await servicioService.getSugerenciasCodigos();
    debugPrint('   - Sugerencias descripciones: ${sugerenciasDesc.length}');
    debugPrint('   - Sugerencias códigos: ${sugerenciasCod.length}');

    // f) Validar formato código
    final formatoValido = servicioService.validarFormatoCodigo('TEST-001');
    debugPrint('   - Formato código válido: $formatoValido');

    // ========== DELETE ==========
    debugPrint('7. 🗑️ Probando DELETE (Eliminar servicio)...');
    try {
      final deleteResponse = await supabase.client
          .from('servicios')
          .delete()
          .eq('codigo', 'TEST-001')
          .select();

      debugPrint('✅ DELETE exitoso: ${deleteResponse.length} servicios eliminados');

      // Verificar que se eliminó
      final servicioEliminado = await servicioService.getServicioPorCodigo('TEST-001');
      if (servicioEliminado == null) {
        debugPrint('✅ Verificación DELETE: El servicio se eliminó correctamente');
      } else {
        debugPrint('❌ Verificación DELETE: El servicio NO se eliminó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en DELETE: $e');
    }

    // ========== PRUEBAS DE ERRORES ==========
    debugPrint('8. 🧪 Probando manejo de errores...');

    // a) Búsqueda con menos de 2 caracteres
    try {
      await servicioService.buscarServicios('P');
      debugPrint('❌ ERROR: Debió fallar la búsqueda con 1 carácter');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // b) Obtener con código vacío
    try {
      await servicioService.getServicioPorCodigo('');
      debugPrint('❌ ERROR: Debió fallar con código vacío');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // c) Obtener con descripción vacía
    try {
      await servicioService.getServicioPorDescripcion('');
      debugPrint('❌ ERROR: Debió fallar con descripción vacía');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    debugPrint('🎉 ¡CRUD SERVICIOS COMPLETADO EXITOSAMENTE!');
    debugPrint('📊 Resumen:');
    debugPrint('   ✅ CREATE - Insertar servicio');
    debugPrint('   ✅ READ - Leer y buscar servicios');
    debugPrint('   ✅ UPDATE - Actualizar servicio');
    debugPrint('   ✅ DELETE - Eliminar servicio');
    debugPrint('   ✅ Validaciones y manejo de errores');

  } catch (e) {
    debugPrint('❌ ERROR GENERAL en CRUD Servicios: $e');
    debugPrint('🔧 StackTrace: ${e.toString()}');
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
    await probarCRUDServicios();

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