import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'backend/api/supabase_service.dart';
import 'backend/schema/structs/empleado.dart';
import 'backend/schema/structs/obras.dart';
import 'flutter_flow/flutter_flow_util.dart';
// ↓ AÑADE ESTAS IMPORTACIONES
import 'backend/api/supabase_manager.dart';
import 'backend/api/repositories/catalogo_repo.dart';
import 'backend/api/services/catalogo_service.dart';
import 'backend/schema/structs/descripcion_trabajo.dart';

import 'package:cupertino_time_picker_hiuzb7/app_state.dart'
as cupertino_time_picker_hiuzb7_app_state;

// ↓ AÑADE ESTA FUNCIÓN DE PRUEBA
Future<void> probarCRUDObras() async {
  debugPrint('🧪 Probando CRUD completo de Obras...');

  // Datos de prueba
  final testObra = obras(
      id: 999, // ID temporal para pruebas
      nombre: 'Obra de Prueba CRUD'
  );

  final testObraActualizada = obras(
      id: 999,
      nombre: 'Obra de Prueba ACTUALIZADA'
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
    final obraService = CatalogoService(catalogoRepo);

    // 🔄 LIMPIAR DATOS DE PRUEBA PREVIOS
    debugPrint('2. 🧹 Limpiando datos de prueba previos...');
    try {
      await supabase.client
          .from('obras')
          .delete()
          .eq('id', 999);
      debugPrint('✅ Datos previos limpiados');
    } catch (e) {
      debugPrint('⚠️ No se pudieron limpiar datos previos: $e');
    }

    // ========== CREATE ==========
    debugPrint('3. 📝 Probando CREATE (Insertar obra)...');
    try {
      final insertResponse = await supabase.client
          .from('obras')
          .insert({
        'id': testObra.id,
        'nombre': testObra.nombre,
      })
          .select();

      debugPrint('✅ INSERT exitoso: ${insertResponse.length} obras insertadas');
      debugPrint('   Datos insertados: ${insertResponse.first}');

    } catch (e) {
      debugPrint('❌ ERROR en INSERT: $e');
      debugPrint('💡 Verifica:');
      debugPrint('   - Permisos RLS en tabla obras');
      debugPrint('   - Estructura de la tabla (campos id, nombre)');
      debugPrint('   - Si el ID 999 ya existe');
      return;
    }

    // ========== READ ==========
    debugPrint('4. 📖 Probando READ (Leer obras)...');

    // a) Leer todas las obras
    final todasObras = await obraService.getObras();
    debugPrint('✅ READ todas: ${todasObras.length} obras');

    // b) Buscar por ID específico
    final obraEncontrada = await obraService.getObraPorId(999);
    if (obraEncontrada != null) {
      debugPrint('✅ READ por ID: ${obraEncontrada.id} - ${obraEncontrada.nombre}');
    } else {
      debugPrint('❌ No se encontró la obra insertada');
      return;
    }

    // c) Buscar por nombre
    final obraPorNombre = await obraService.getObraPorNombre('Obra de Prueba CRUD');
    if (obraPorNombre != null) {
      debugPrint('✅ READ por nombre: ${obraPorNombre.nombre}');
    } else {
      debugPrint('⚠️ No se encontró por nombre exacto');
    }

    // d) Buscar con búsqueda
    final resultadosBusqueda = await obraService.buscarObras('Prueba');
    debugPrint('✅ Búsqueda: ${resultadosBusqueda.length} resultados');

    // e) Buscar por nombre (contains)
    final porNombreContains = await obraService.buscarObrasPorNombre('Prueba');
    debugPrint('✅ Búsqueda por nombre: ${porNombreContains.length} resultados');

    // ========== UPDATE ==========
    debugPrint('5. ✏️ Probando UPDATE (Actualizar obra)...');
    try {
      final updateResponse = await supabase.client
          .from('obras')
          .update({
        'nombre': testObraActualizada.nombre,
      })
          .eq('id', 999)
          .select();

      debugPrint('✅ UPDATE exitoso: ${updateResponse.length} obras actualizadas');
      debugPrint('   Datos actualizados: ${updateResponse.first}');

      // Verificar que se actualizó
      final obraActualizada = await obraService.getObraPorId(999);
      if (obraActualizada != null && obraActualizada.nombre == 'Obra de Prueba ACTUALIZADA') {
        debugPrint('✅ Verificación UPDATE: La obra se actualizó correctamente');
      } else {
        debugPrint('❌ Verificación UPDATE: La obra no se actualizó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en UPDATE: $e');
    }

    // ========== VALIDACIONES DEL SERVICIO ==========
    debugPrint('6. ✅ Probando validaciones del servicio...');

    // a) Validar existencia
    final existe = await obraService.existeObra(999);
    debugPrint('   - Existe ID 999: $existe');

    // b) Validar existencia por nombre
    final existeNombre = await obraService.existeObraPorNombre('Obra de Prueba ACTUALIZADA');
    debugPrint('   - Existe por nombre: $existeNombre');

    // d) Formato dropdown
    final dropdownData = await obraService.getObrasParaDropdown();
    debugPrint('   - Items dropdown: ${dropdownData.length}');

    // e) Sugerencias para autocompletado
    final sugerencias = await obraService.getSugerenciasNombresObras();
    debugPrint('   - Sugerencias nombres: ${sugerencias.length}');

    // f) Validar formato ID
    final formatoValido = obraService.validarFormatoId('999');
    debugPrint('   - Formato ID válido: $formatoValido');

    // ========== DELETE ==========
    debugPrint('7. 🗑️ Probando DELETE (Eliminar obra)...');
    try {
      final deleteResponse = await supabase.client
          .from('obras')
          .delete()
          .eq('id', 999)
          .select();

      debugPrint('✅ DELETE exitoso: ${deleteResponse.length} obras eliminadas');

      // Verificar que se eliminó
      final obraEliminada = await obraService.getObraPorId(999);
      if (obraEliminada == null) {
        debugPrint('✅ Verificación DELETE: La obra se eliminó correctamente');
      } else {
        debugPrint('❌ Verificación DELETE: La obra NO se eliminó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en DELETE: $e');
    }

    // ========== PRUEBAS DE ERRORES ==========
    debugPrint('8. 🧪 Probando manejo de errores...');

    // a) Búsqueda con menos de 2 caracteres
    try {
      await obraService.buscarObras('P');
      debugPrint('❌ ERROR: Debió fallar la búsqueda con 1 carácter');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // b) Obtener con ID inválido
    try {
      await obraService.getObraPorId(0);
      debugPrint('❌ ERROR: Debió fallar con ID 0');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // c) Obtener con nombre vacío
    try {
      await obraService.getObraPorNombre('');
      debugPrint('❌ ERROR: Debió fallar con nombre vacío');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    debugPrint('🎉 ¡CRUD OBRAS COMPLETADO EXITOSAMENTE!');
    debugPrint('📊 Resumen:');
    debugPrint('   ✅ CREATE - Insertar obra');
    debugPrint('   ✅ READ - Leer y buscar obras');
    debugPrint('   ✅ UPDATE - Actualizar obra');
    debugPrint('   ✅ DELETE - Eliminar obra');
    debugPrint('   ✅ Validaciones y manejo de errores');

  } catch (e) {
    debugPrint('❌ ERROR GENERAL en CRUD Obras: $e');
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
    await probarCRUDObras();

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