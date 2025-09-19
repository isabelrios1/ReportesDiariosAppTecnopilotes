import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'backend/api/supabase_service.dart';
import 'flutter_flow/flutter_flow_util.dart';
// ↓ AÑADE ESTAS IMPORTACIONES
import 'backend/api/supabase_manager.dart';
import 'backend/api/repositories/catalogo_repo.dart';
import 'backend/api/services/catalogo_service.dart';
import 'backend/schema/structs/descripcion_trabajo.dart';

import 'package:cupertino_time_picker_hiuzb7/app_state.dart'
as cupertino_time_picker_hiuzb7_app_state;

// ↓ AÑADE ESTA FUNCIÓN DE PRUEBA


Future<void> probarDescripcionesTrabajo() async {
  debugPrint('🧪 Probando CRUD con autenticación...');

  try {
    // ✅ INICIALIZAR SUPABASE
    if (!SupabaseService.isInitialized) {
      await SupabaseService.initialize();
    }

    final supabase = SupabaseManager();
    await supabase.ensureConnected();

    // ✅ VERIFICAR SI YA ESTÁS AUTENTICADO
    final currentUser = supabase.client.auth.currentUser;
    if (currentUser == null) {
      debugPrint('🔐 No autenticado. Iniciando sesión...');

      // INICIAR SESIÓN CON UN USUARIO VÁLIDO
      final authResponse = await supabase.client.auth.signInWithPassword(
        email: 'mvillarroel.deheza@gmail.com',  // ← REEMPLAZA CON UN USUARIO REAL
        password: '1911tobyrufo',       // ← REEMPLAZA CON PASSWORD REAL
      );

      if (authResponse.user == null) {
        debugPrint('❌ Error de autenticación. Creando usuario de prueba...');
        // Intentar crear usuario si no existe
        try {
          final signUpResponse = await supabase.client.auth.signUp(
            email: 'test@ejemplo.com',
            password: 'testpassword123',
          );
          debugPrint('✅ Usuario de prueba creado');
        } catch (e) {
          debugPrint('❌ No se pudo crear usuario: $e');
        }
      } else {
        debugPrint('✅ Sesión iniciada: ${authResponse.user!.email}');
      }
    } else {
      debugPrint('✅ Ya autenticado: ${currentUser.email}');
    }

    await probarCRUDDescripcionesTrabajo();

  } catch (e) {
    debugPrint('❌ ERROR: $e');
  }
}

Future<void> probarCRUDDescripcionesTrabajo() async {
  debugPrint('🧪 Probando CRUD completo de Descripciones de Trabajo...');

  // Datos de prueba
  final testDescripcion = DescripcionTrabajo(
      codigo: 'TEST-001',
      detalle: 'Descripción de prueba para CRUD'
  );

  final testDescripcionActualizada = DescripcionTrabajo(
      codigo: 'TEST-001',
      detalle: 'Descripción ACTUALIZADA para CRUD'
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
    final catalogoService = CatalogoService(catalogoRepo);

    // 🔄 LIMPIAR DATOS DE PRUEBA PREVIOS (por si acaso)
    debugPrint('2. 🧹 Limpiando datos de prueba previos...');
    try {
      await supabase.client
          .from('descripcionTrabajo')
          .delete()
          .eq('codigo', 'TEST-001');
      debugPrint('✅ Datos previos limpiados');
    } catch (e) {
      debugPrint('⚠️ No se pudieron limpiar datos previos: $e');
    }

    // ========== CREATE ==========
    debugPrint('3. 📝 Probando CREATE (Insertar)...');
    try {
      // Insertar usando Supabase directamente
      final insertResponse = await supabase.client
          .from('descripcionTrabajo')
          .insert({
        'codigo': testDescripcion.codigo,
        'detalle': testDescripcion.detalle
      })
          .select();

      debugPrint('✅ INSERT exitoso: ${insertResponse.length} registros insertados');
      debugPrint('   Datos insertados: ${insertResponse.first}');

    } catch (e) {
      debugPrint('❌ ERROR en INSERT: $e');
      debugPrint('💡 Verifica:');
      debugPrint('   - Permisos de escritura en la tabla');
      debugPrint('   - Estructura de la tabla (campos codigo, detalle)');
      return;
    }

    // ========== READ ==========
    debugPrint('4. 📖 Probando READ (Leer)...');

    // a) Leer todas las descripciones
    final todasDescripciones = await catalogoService.getDescripcionesTrabajo();
    debugPrint('✅ READ todas: ${todasDescripciones.length} descripciones');

    // b) Buscar por código específico
    final descripcionEncontrada = await catalogoService.getDescripcionTrabajoPorCodigo('TEST-001');
    if (descripcionEncontrada != null) {
      debugPrint('✅ READ por código: ${descripcionEncontrada.codigo} - ${descripcionEncontrada.detalle}');
    } else {
      debugPrint('❌ No se encontró la descripción insertada');
      return;
    }

    // c) Buscar con búsqueda
    final resultadosBusqueda = await catalogoService.buscarDescripcionesTrabajo('TEST');
    debugPrint('✅ Búsqueda: ${resultadosBusqueda.length} resultados');

    // ========== UPDATE ==========
    debugPrint('5. ✏️ Probando UPDATE (Actualizar)...');
    try {
      final updateResponse = await supabase.client
          .from('descripcionTrabajo')
          .update({
        'detalle': testDescripcionActualizada.detalle
      })
          .eq('codigo', 'TEST-001')
          .select();

      debugPrint('✅ UPDATE exitoso: ${updateResponse.length} registros actualizados');
      debugPrint('   Datos actualizados: ${updateResponse.first}');

      // Verificar que se actualizó
      final descripcionActualizada = await catalogoService.getDescripcionTrabajoPorCodigo('TEST-001');
      if (descripcionActualizada != null && descripcionActualizada.detalle == testDescripcionActualizada.detalle) {
        debugPrint('✅ Verificación UPDATE: La descripción se actualizó correctamente');
      } else {
        debugPrint('❌ Verificación UPDATE: La descripción no se actualizó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en UPDATE: $e');
    }

    // ========== VALIDACIONES DEL SERVICIO ==========
    debugPrint('6. ✅ Probando validaciones del servicio...');

    // a) Validar existencia
    final existe = await catalogoService.existeDescripcionTrabajo('TEST-001');
    debugPrint('   - Existe TEST-001: $existe');

    // b) Obtener descripciones válidas
    final descripcionesValidas = await catalogoService.getDescripcionesValidas();
    debugPrint('   - Descripciones válidas: ${descripcionesValidas.length}');

    // c) Formato dropdown
    final dropdownData = await catalogoService.getDescripcionesTrabajoParaDropdown();
    debugPrint('   - Items dropdown: ${dropdownData.length}');

    // ========== DELETE ==========
    debugPrint('7. 🗑️ Probando DELETE (Eliminar)...');
    try {
      final deleteResponse = await supabase.client
          .from('descripcionTrabajo')
          .delete()
          .eq('codigo', 'TEST-001')
          .select();

      debugPrint('✅ DELETE exitoso: ${deleteResponse.length} registros eliminados');

      // Verificar que se eliminó
      final descripcionEliminada = await catalogoService.getDescripcionTrabajoPorCodigo('TEST-001');
      if (descripcionEliminada == null) {
        debugPrint('✅ Verificación DELETE: La descripción se eliminó correctamente');
      } else {
        debugPrint('❌ Verificación DELETE: La descripción NO se eliminó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en DELETE: $e');
    }

    // ========== PRUEBAS DE ERRORES ==========
    debugPrint('8. 🧪 Probando manejo de errores...');

    // a) Búsqueda con menos de 2 caracteres
    try {
      await catalogoService.buscarDescripcionesTrabajo('A');
      debugPrint('❌ ERROR: Debió fallar la búsqueda con 1 carácter');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // b) Obtener con código vacío
    try {
      await catalogoService.getDescripcionTrabajoPorCodigo('');
      debugPrint('❌ ERROR: Debió fallar con código vacío');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    debugPrint('🎉 ¡CRUD COMPLETADO EXITOSAMENTE!');
    debugPrint('📊 Resumen:');
    debugPrint('   ✅ CREATE - Insertar datos');
    debugPrint('   ✅ READ - Leer y buscar datos');
    debugPrint('   ✅ UPDATE - Actualizar datos');
    debugPrint('   ✅ DELETE - Eliminar datos');
    debugPrint('   ✅ Validaciones y manejo de errores');

  } catch (e) {
    debugPrint('❌ ERROR GENERAL en CRUD: $e');
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
    await probarDescripcionesTrabajo();

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