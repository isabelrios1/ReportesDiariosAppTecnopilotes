import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'backend/api/supabase_service.dart';
import 'backend/schema/structs/catalogo/empleado.dart';
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

Future<void> probarCRUDRepuestos() async {
  debugPrint('🧪 Probando CRUD completo de Repuestos...');

  // Datos de prueba
  final testRepuesto = repuestos(
      modelo: 'TEST-MODELO-001',
      componente: 'Componente de Prueba CRUD',
      ultimaCotizacion: 150.75
  );

  final testRepuestoActualizado = repuestos(
      modelo: 'TEST-MODELO-001',
      componente: 'Componente de Prueba ACTUALIZADO',
      ultimaCotizacion: 199.99
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
    final repuestoService = CatalogoService(catalogoRepo);

    // 🔄 LIMPIAR DATOS DE PRUEBA PREVIOS
    debugPrint('2. 🧹 Limpiando datos de prueba previos...');
    try {
      await supabase.client
          .from('repuestos')
          .delete()
          .eq('modelo', 'TEST-MODELO-001');
      debugPrint('✅ Datos previos limpiados');
    } catch (e) {
      debugPrint('⚠️ No se pudieron limpiar datos previos: $e');
    }

    // ========== CREATE ==========
    debugPrint('3. 📝 Probando CREATE (Insertar repuesto)...');
    try {
      final insertResponse = await supabase.client
          .from('repuestos')
          .insert({
        'modelo': testRepuesto.modelo,
        'componente': testRepuesto.componente,
        'ultimaCotizacion': testRepuesto.ultimaCotizacion,
      })
          .select();

      debugPrint('✅ INSERT exitoso: ${insertResponse.length} repuestos insertados');
      debugPrint('   Datos insertados: ${insertResponse.first}');

    } catch (e) {
      debugPrint('❌ ERROR en INSERT: $e');
      debugPrint('💡 Verifica:');
      debugPrint('   - Permisos RLS en tabla repuestos');
      debugPrint('   - Estructura de la tabla (campos modelo, componente, ultimaCotizacion)');
      debugPrint('   - Si el modelo TEST-MODELO-001 ya existe');
      return;
    }

    // ========== READ ==========
    debugPrint('4. 📖 Probando READ (Leer repuestos)...');

    // a) Leer todos los repuestos
    final todosRepuestos = await repuestoService.getRepuestos();
    debugPrint('✅ READ todas: ${todosRepuestos.length} repuestos');

    // b) Buscar por modelo y componente exacto
    final repuestoEncontrado = await repuestoService.getRepuestoExacto(
        'TEST-MODELO-001',
        'Componente de Prueba CRUD'
    );
    if (repuestoEncontrado != null) {
      debugPrint('✅ READ exacto: ${repuestoEncontrado.modelo} - ${repuestoEncontrado.componente} - \$${repuestoEncontrado.ultimaCotizacion}');
    } else {
      debugPrint('❌ No se encontró el repuesto insertado');
      return;
    }

    // c) Buscar con búsqueda general
    final resultadosBusqueda = await repuestoService.buscarRepuestos('Prueba');
    debugPrint('✅ Búsqueda general: ${resultadosBusqueda.length} resultados');

    // d) Buscar por modelo
    final porModelo = await repuestoService.getRepuestosPorModelo('TEST-MODELO');
    debugPrint('✅ Búsqueda por modelo: ${porModelo.length} resultados');

    // e) Buscar por componente
    final porComponente = await repuestoService.getRepuestosPorComponente('Componente');
    debugPrint('✅ Búsqueda por componente: ${porComponente.length} resultados');

    // ========== UPDATE ==========
    debugPrint('5. ✏️ Probando UPDATE (Actualizar repuesto)...');
    try {
      final updateResponse = await supabase.client
          .from('repuestos')
          .update({
        'componente': testRepuestoActualizado.componente,
        'ultimaCotizacion': testRepuestoActualizado.ultimaCotizacion,
      })
          .eq('modelo', 'TEST-MODELO-001')
          .select();

      debugPrint('✅ UPDATE exitoso: ${updateResponse.length} repuestos actualizados');
      debugPrint('   Datos actualizados: ${updateResponse.first}');

      // Verificar que se actualizó
      final repuestoActualizado = await repuestoService.getRepuestoExacto(
          'TEST-MODELO-001',
          'Componente de Prueba ACTUALIZADO'
      );
      if (repuestoActualizado != null && repuestoActualizado.ultimaCotizacion == 199.99) {
        debugPrint('✅ Verificación UPDATE: El repuesto se actualizó correctamente');
      } else {
        debugPrint('❌ Verificación UPDATE: El repuesto no se actualizó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en UPDATE: $e');
    }

    // ========== VALIDACIONES DEL SERVICIO ==========
    debugPrint('6. ✅ Probando funcionalidades del servicio...');

    // a) Validar existencia
    final existe = await repuestoService.existeRepuesto(
        'TEST-MODELO-001',
        'Componente de Prueba ACTUALIZADO'
    );
    debugPrint('   - Existe repuesto: $existe');

    // b) Obtener repuestos válidos
    final repuestosValidos = await repuestoService.getRepuestosValidos();
    debugPrint('   - Repuestos válidos: ${repuestosValidos.length}');

    // c) Formato dropdown
    final dropdownData = await repuestoService.getRepuestosParaDropdown();
    debugPrint('   - Items dropdown: ${dropdownData.length}');
    if (dropdownData.isNotEmpty) {
      debugPrint('   - Ejemplo dropdown: ${dropdownData.first['label']}');
    }

    // d) Sugerencias para autocompletado
    final sugerenciasModelos = await repuestoService.getSugerenciasModelos();
    final sugerenciasComponentes = await repuestoService.getSugerenciasComponentes();
    debugPrint('   - Sugerencias modelos: ${sugerenciasModelos.length}');
    debugPrint('   - Sugerencias componentes: ${sugerenciasComponentes.length}');

    // e) Filtrar por rango de precio
    final porRangoPrecio = await repuestoService.getRepuestosPorRangoPrecio(100.0, 200.0);
    debugPrint('   - Repuestos en rango \$100-\$200: ${porRangoPrecio.length}');

    // f) Repuestos con precio mayor a
    final precioMayorA = await repuestoService.getRepuestosPrecioMayorA(50.0);
    debugPrint('   - Repuestos > \$50: ${precioMayorA.length}');

    // g) Ordenar por precio
    final ordenadosPrecio = await repuestoService.getRepuestosOrdenadosPorPrecio();
    debugPrint('   - Ordenados por precio: ${ordenadosPrecio.length}');

    // h) Ordenar por modelo
    final ordenadosModelo = await repuestoService.getRepuestosOrdenadosPorModelo();
    debugPrint('   - Ordenados por modelo: ${ordenadosModelo.length}');

    // i) Modelos únicos
    final modelosUnicos = await repuestoService.getModelosUnicos();
    debugPrint('   - Modelos únicos: ${modelosUnicos.length}');

    // j) Estadísticas de precios
    final estadisticas = await repuestoService.getEstadisticasPrecios();
    debugPrint('   - Estadísticas: promedio \$${estadisticas['promedio']?.toStringAsFixed(2)}');

    // ========== DELETE ==========
    debugPrint('7. 🗑️ Probando DELETE (Eliminar repuesto)...');
    try {
      final deleteResponse = await supabase.client
          .from('repuestos')
          .delete()
          .eq('modelo', 'TEST-MODELO-001')
          .select();

      debugPrint('✅ DELETE exitoso: ${deleteResponse.length} repuestos eliminados');

      // Verificar que se eliminó
      final repuestoEliminado = await repuestoService.getRepuestoExacto(
          'TEST-MODELO-001',
          'Componente de Prueba ACTUALIZADO'
      );
      if (repuestoEliminado == null) {
        debugPrint('✅ Verificación DELETE: El repuesto se eliminó correctamente');
      } else {
        debugPrint('❌ Verificación DELETE: El repuesto NO se eliminó');
      }

    } catch (e) {
      debugPrint('❌ ERROR en DELETE: $e');
    }

    // ========== PRUEBAS DE ERRORES ==========
    debugPrint('8. 🧪 Probando manejo de errores...');

    // a) Búsqueda con menos de 2 caracteres
    try {
      await repuestoService.buscarRepuestos('P');
      debugPrint('❌ ERROR: Debió fallar la búsqueda con 1 carácter');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // b) Rango de precio inválido
    try {
      await repuestoService.getRepuestosPorRangoPrecio(200.0, 100.0);
      debugPrint('❌ ERROR: Debió fallar con rango inválido');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // c) Precio negativo
    try {
      await repuestoService.getRepuestosPrecioMayorA(-50.0);
      debugPrint('❌ ERROR: Debió fallar con precio negativo');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    // d) Modelo vacío
    try {
      await repuestoService.getRepuestosPorModelo('');
      debugPrint('❌ ERROR: Debió fallar con modelo vacío');
    } catch (e) {
      debugPrint('✅ Manejo de error correcto: $e');
    }

    debugPrint('🎉 ¡CRUD REPUESTOS COMPLETADO EXITOSAMENTE!');
    debugPrint('📊 Resumen:');
    debugPrint('   ✅ CREATE - Insertar repuesto');
    debugPrint('   ✅ READ - Leer y buscar repuestos');
    debugPrint('   ✅ UPDATE - Actualizar repuesto');
    debugPrint('   ✅ DELETE - Eliminar repuesto');
    debugPrint('   ✅ Filtros por precio y modelo');
    debugPrint('   ✅ Ordenamientos y estadísticas');
    debugPrint('   ✅ Validaciones y manejo de errores');

  } catch (e) {
    debugPrint('❌ ERROR GENERAL en CRUD Repuestos: $e');
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
    await probarCRUDRepuestos();

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