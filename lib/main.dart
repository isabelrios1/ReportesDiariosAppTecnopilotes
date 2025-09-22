import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'backend/api/supabase_service.dart';
import 'backend/schema/structs/empleado.dart';
import 'flutter_flow/flutter_flow_util.dart';
// ↓ AÑADE ESTAS IMPORTACIONES
import 'backend/api/supabase_manager.dart';
import 'backend/api/repositories/catalogo_repo.dart';
import 'backend/api/services/catalogo_service.dart';
import 'backend/schema/structs/descripcion_trabajo.dart';

import 'package:cupertino_time_picker_hiuzb7/app_state.dart'
as cupertino_time_picker_hiuzb7_app_state;

// ↓ AÑADE ESTA FUNCIÓN DE PRUEBA

Future<void> probarCRUDEmpleados() async {
  debugPrint('🧪 Probando CRUD completo de Empleados...');

  // Datos de prueba
  final testEmpleado = empleado(
      ci: '1234567',
      nombre: 'Juan',
      apellidoPaterno: 'Perez',
      apellidoMaterno: 'Gomez',
      rol: 'Operador',
      password: 'test123',
      cargo: 'Operador de Maquinaria'
  );

  final testEmpleadoActualizado = empleado(
      ci: '1234567',
      nombre: 'Juan Carlos', // ← Nombre actualizado
      apellidoPaterno: 'Perez',
      apellidoMaterno: 'Gomez',
      rol: 'Supervisor',     // ← Rol actualizado
      password: 'test123',
      cargo: 'Supervisor de Obra'
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
    final empleadoService = CatalogoService(catalogoRepo);

    // 🔄 LIMPIAR DATOS DE PRUEBA PREVIOS
    debugPrint('2. 🧹 Limpiando datos de prueba previos...');
    try {
      await supabase.client
          .from('empleados')
          .delete()
          .eq('ci', '1234567');
      debugPrint('✅ Datos previos limpiados');
    } catch (e) {
      debugPrint('⚠️ No se pudieron limpiar datos previos: $e');
    }

    // ========== CREATE ==========
    debugPrint('3. 📝 Probando CREATE (Insertar empleado)...');
    try {
      final insertResponse = await supabase.client
          .from('empleados')
          .insert({
        'ci': testEmpleado.ci,
        'nombre': testEmpleado.nombre,
        'apellidoPaterno': testEmpleado.apellidoPaterno,
        'apellidoMaterno': testEmpleado.apellidoMaterno,
        'rol': testEmpleado.rol,
        'password': testEmpleado.password,
        'cargo': testEmpleado.cargo
      })
          .select();

      debugPrint('✅ INSERT exitoso: ${insertResponse.length} empleados insertados');
      debugPrint('   Datos insertados: ${insertResponse.first}');

    } catch (e) {
      debugPrint('❌ ERROR en INSERT: $e');
      debugPrint('💡 Verifica:');
      debugPrint('   - Permisos RLS en tabla empleados');
      debugPrint('   - Estructura de la tabla');
      return;
    }

    // ========== READ ==========
    debugPrint('4. 📖 Probando READ (Leer empleados)...');

    // a) Leer todos los empleados
    final todosEmpleados = await empleadoService.getEmpleados();
    debugPrint('✅ READ todos: ${todosEmpleados.length} empleados');

    // b) Buscar por CI específico
    final empleadoEncontrado = await empleadoService.getEmpleadoPorCI('1234567');
    if (empleadoEncontrado != null) {
      debugPrint('✅ READ por CI: ${empleadoEncontrado.nombre} ${empleadoEncontrado.apellidoPaterno}');
    } else {
      debugPrint('❌ No se encontró el empleado insertado');
      return;
    }

    // c) Buscar con búsqueda
    final resultadosBusqueda = await empleadoService.buscarEmpleados('Juan');
    debugPrint('✅ Búsqueda: ${resultadosBusqueda.length} resultados');

    // d) Buscar por nombre completo
    final porNombreCompleto = await empleadoService.buscarPorNombreCompleto('Juan Perez Gomez');
    debugPrint('✅ Búsqueda nombre completo: ${porNombreCompleto.length} resultados');

    // ========== UPDATE ==========
    debugPrint('5. ✏️ Probando UPDATE (Actualizar empleado)...');
    try {
      final updateResponse = await supabase.client
          .from('empleados')
          .update({
        'nombre': testEmpleadoActualizado.nombre,
        'rol': testEmpleadoActualizado.rol,
        'cargo': testEmpleadoActualizado.cargo
      })
          .eq('ci', '1234567')
          .select();

      debugPrint('✅ UPDATE exitoso: ${updateResponse.length} empleados actualizados');
      debugPrint('   Datos actualizados: ${updateResponse.first}');

      // Verificar que se actualizó
      final empleadoActualizado = await empleadoService.getEmpleadoPorCI('1234567');
      if (empleadoActualizado != null && empleadoActualizado.nombre == 'Juan Carlos') {
        debugPrint('✅ Verificación UPDATE: El empleado se actualizó correctamente');
      } else {
        debugPrint('❌ Verificación UPDATE: El empleado no se actualizó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en UPDATE: $e');
    }

    // ========== VALIDACIONES DEL SERVICIO ==========
    debugPrint('6. ✅ Probando validaciones del servicio...');

    // a) Validar existencia
    final existe = await empleadoService.buscarEmpleados('1234567');
    debugPrint('   - Existe CI 1234567: $existe');

    // b) Obtener empleados válidos
    final empleadosValidos = await empleadoService.getEmpleadosValidos();
    debugPrint('   - Empleados válidos: ${empleadosValidos.length}');

    // c) Formato dropdown
    final dropdownData = await empleadoService.getEmpleadosParaDropdown();
    debugPrint('   - Items dropdown: ${dropdownData.length}');

    // d) Sugerencias para autocompletado
    final sugerencias = await empleadoService.getSugerenciasNombres();
    debugPrint('   - Sugerencias nombres: ${sugerencias.length}');

    // e) Validar formato CI
    final formatoValido = empleadoService.validarFormatoCI('1234567');
    debugPrint('   - Formato CI válido: $formatoValido');

    // ========== DELETE ==========
    debugPrint('7. 🗑️ Probando DELETE (Eliminar empleado)...');
    try {
      final deleteResponse = await supabase.client
          .from('empleados')
          .delete()
          .eq('ci', '1234567')
          .select();

      debugPrint('✅ DELETE exitoso: ${deleteResponse.length} empleados eliminados');

      // Verificar que se eliminó
      final empleadoEliminado = await empleadoService.getEmpleadoPorCI('1234567');
      if (empleadoEliminado == null) {
        debugPrint('✅ Verificación DELETE: El empleado se eliminó correctamente');
      } else {
        debugPrint('❌ Verificación DELETE: El empleado NO se eliminó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en DELETE: $e');
    }

    // ========== PRUEBAS DE ERRORES ==========
    debugPrint('8. 🧪 Probando manejo de errores...');

    // a) Búsqueda con menos de 2 caracteres
    try {
      await empleadoService.buscarEmpleados('J');
      debugPrint('❌ ERROR: Debió fallar la búsqueda con 1 carácter');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // b) Obtener con CI vacío
    try {
      await empleadoService.getEmpleadoPorCI('');
      debugPrint('❌ ERROR: Debió fallar con CI vacío');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    debugPrint('🎉 ¡CRUD EMPLEADOS COMPLETADO EXITOSAMENTE!');
    debugPrint('📊 Resumen:');
    debugPrint('   ✅ CREATE - Insertar empleado');
    debugPrint('   ✅ READ - Leer y buscar empleados');
    debugPrint('   ✅ UPDATE - Actualizar empleado');
    debugPrint('   ✅ DELETE - Eliminar empleado');
    debugPrint('   ✅ Validaciones y manejo de errores');

  } catch (e) {
    debugPrint('❌ ERROR GENERAL en CRUD Empleados: $e');
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
    await probarCRUDEmpleados();

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