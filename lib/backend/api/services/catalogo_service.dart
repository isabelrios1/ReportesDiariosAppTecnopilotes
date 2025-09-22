import 'package:reportes_diarios/backend/schema/structs/catalogo/empleado.dart';
import 'package:collection/collection.dart';
import '../../schema/structs/catalogo/obras.dart';
import '../../schema/structs/catalogo/repuestos.dart';
import '../../schema/structs/catalogo/servicio.dart';
import '../repositories/catalogo_repo.dart';
import '../../schema/structs/catalogo/descripcion_trabajo.dart';

class CatalogoService {
  final CatalogoRepository catalogoRepo;

  CatalogoService(this.catalogoRepo);

  // ================================= DESCRIPCIONES DE TRABAJO =================================
  Future<List<DescripcionTrabajo>> getDescripcionesTrabajo() async {
    return await catalogoRepo.getDescripcionesTrabajo();
  }

  Future<List<DescripcionTrabajo>> buscarDescripcionesTrabajo(String query) async {
    if (query.length < 2) {
      throw Exception('La búsqueda requiere al menos 2 caracteres');
    }

    return await catalogoRepo.buscarDescripcionesTrabajo(query);
  }

  Future<DescripcionTrabajo?> getDescripcionTrabajoPorCodigo(String codigo) async {
    if (codigo.isEmpty) {
      throw Exception('El código no puede estar vacío');
    }

    return await catalogoRepo.getDescripcionTrabajoPorCodigo(codigo);
  }

  // Para dropdowns en UI - formato optimizado
  Future<List<Map<String, dynamic>>> getDescripcionesTrabajoParaDropdown() async {
    final descripciones = await catalogoRepo.getDescripcionesTrabajo();

    return descripciones.map((desc) => {
      'value': desc.codigo,  // ← Usamos el código como valor
      'label': '${desc.codigo} - ${desc.detalle}',
      'object': desc, // Objeto completo por si se necesita
    }).toList();
  }

  // Validar si una descripción existe
  Future<bool> existeDescripcionTrabajo(String codigo) async {
    final descripcion = await catalogoRepo.getDescripcionTrabajoPorCodigo(codigo);
    return descripcion != null;
  }

  // Filtrar descripciones válidas
  Future<List<DescripcionTrabajo>> getDescripcionesValidas() async {
    final todas = await catalogoRepo.getDescripcionesTrabajo();
    return todas.where((desc) => desc.esValido).toList();
  }

// ================================== EMPLEADOS =================================

  Future<List<empleado>> getEmpleados() async {
    return await catalogoRepo.getEmpleados();
  }

  Future<List<empleado>> buscarEmpleados(String query) async {
    if (query.isEmpty) {
      return await getEmpleados(); // Si no hay query, devolver todos
    }

    if (query.length < 2) {
      throw Exception('Ingresa al menos 2 caracteres para buscar');
    }

    return await catalogoRepo.buscarEmpleados(query);
  }

  Future<empleado?> getEmpleadoPorCI(String ci) async {
    if (ci.isEmpty) {
      throw Exception('La cédula de identidad no puede estar vacía');
    }

    final todosEmpleados = await catalogoRepo.getEmpleados();
    return todosEmpleados
        .where((empleado) => empleado.ci == ci)
        .firstOrNull; // ← firstOrNull es más claro
  }

  // Para dropdowns en UI - formato optimizado
  Future<List<Map<String, dynamic>>> getEmpleadosParaDropdown() async {
    final empleados = await catalogoRepo.getEmpleados();

    return empleados.map((emp) => {
      'value': emp.ci,
      'label': '${emp.nombre} ${emp.apellidoPaterno} ${emp.apellidoMaterno}',
      'object': emp,
    }).toList();
  }

  // Buscar empleados por nombre completo (útil para búsquedas naturales)
  Future<List<empleado>> buscarPorNombreCompleto(String nombreCompleto) async {
    if (nombreCompleto.isEmpty) {
      return await getEmpleados();
    }

    if (nombreCompleto.length < 2) {
      throw Exception('Ingresa al menos 2 caracteres para buscar');
    }

    final todosEmpleados = await catalogoRepo.getEmpleados();
    final partes = nombreCompleto.toLowerCase().split(' ');

    return todosEmpleados.where((emp) {
      final nombreCompletoEmp = '${emp.nombre} ${emp.apellidoPaterno} ${emp.apellidoMaterno}'.toLowerCase();
      return partes.every((parte) => nombreCompletoEmp.contains(parte));
    }).toList();
  }

  // Filtrar empleados válidos (con datos completos)
  Future<List<empleado>> getEmpleadosValidos() async {
    final todos = await catalogoRepo.getEmpleados();
    return todos.where((emp) => emp.esValido).toList();
  }

  // Obtener sugerencias para autocompletado
  Future<List<String>> getSugerenciasNombresEmpleados() async {
    final empleados = await catalogoRepo.getEmpleados();
    return empleados.map((emp) => '${emp.nombre} ${emp.apellidoPaterno} ${emp.apellidoMaterno}').toList();
  }

  // Validar formato de CI (opcional)
  bool validarFormatoCI(String ci) {
    if (ci.isEmpty) return false;
    // Validar que sea numérico y tenga longitud razonable
    final regex = RegExp(r'^\d{5,10}$');
    return regex.hasMatch(ci);
  }

  // Buscar empleados con filtros combinados
  Future<List<empleado>> buscarEmpleadosConFiltros({
    String? nombre,
    String? ci,
    String? cargo,
  }) async {
    final todosEmpleados = await catalogoRepo.getEmpleados();

    return todosEmpleados.where((emp) {
      bool coincide = true;

      if (nombre != null && nombre.isNotEmpty) {
        final nombreCompleto = '${emp.nombre} ${emp.apellidoPaterno} ${emp.apellidoMaterno}'.toLowerCase();
        coincide = coincide && nombreCompleto.contains(nombre.toLowerCase());
      }

      if (ci != null && ci.isNotEmpty) {
        coincide = coincide && emp.ci.contains(ci);
      }

      if (cargo != null && cargo.isNotEmpty) {
        coincide = coincide && emp.cargo.toLowerCase().contains(cargo.toLowerCase());
      }

      return coincide;
    }).toList();
  }


// ================================== EMPLEADOS =================================

  Future<List<obras>> getObras() async {
    return await catalogoRepo.getObras();
  }

  Future<List<obras>> buscarObras(String query) async {
    if (query.isEmpty) {
      return await getObras(); // Si no hay query, devolver todas
    }
    if (query.length < 2) {
      throw Exception('Ingresa al menos 2 caracteres para buscar');
    }

    return await catalogoRepo.buscarObras(query);
  }

  Future<obras?> getObraPorId(int id) async {
    if (id <= 0) {
      throw Exception('El ID de la obra debe ser mayor a 0');
    }

    final todasObras = await catalogoRepo.getObras();
    return todasObras.firstWhereOrNull((obra) => obra.id == id);
  }

  Future<obras?> getObraPorNombre(String nombre) async {
    if (nombre.isEmpty) throw Exception('El nombre no puede estar vacío');
    final todasObras = await catalogoRepo.getObras();
    return todasObras.firstWhereOrNull(
          (obra) => obra.nombre.toLowerCase() == nombre.toLowerCase(),
    );
  }

  //Dropdown
  Future<List<Map<String, dynamic>>> getObrasParaDropdown() async {
    final obras = await catalogoRepo.getObras();

    return obras.map((obra) => {
      'value': obra.id,  // ← Usamos el ID como valor
      'label': obra.nombre,
      'object': obra, // Objeto completo por si se necesita
    }).toList();
  }

  // Buscar obras que contengan texto en el nombre
  Future<List<obras>> buscarObrasPorNombre(String nombre) async {
    if (nombre.isEmpty) {
      return await getObras();
    }

    if (nombre.length < 2) {
      throw Exception('Ingresa al menos 2 caracteres para buscar');
    }

    final todasObras = await catalogoRepo.getObras();
    return todasObras.where((obra) =>
        obra.nombre.toLowerCase().contains(nombre.toLowerCase())
    ).toList();
  }

  // Validar si una obra existe
  Future<bool> existeObra(int id) async {
    final obra = await getObraPorId(id);
    return obra != null;
  }

  // Validar si existe obra por nombre
  Future<bool> existeObraPorNombre(String nombre) async {
    final obra = await getObraPorNombre(nombre);
    return obra != null;
  }

  // Obtener sugerencias para autocompletado
  Future<List<String>> getSugerenciasNombresObras() async {
    final obras = await catalogoRepo.getObras();
    return obras.map((obra) => obra.nombre).toList();
  }

  // Validar formato de ID
  bool validarFormatoId(String idStr) {
    if (idStr.isEmpty) return false;
    final id = int.tryParse(idStr);
    return id != null && id > 0;
  }


// ================================== SERVICIOS =================================
  Future<List<servicios>> getServicios() async {
    return await catalogoRepo.getServicios();
  }

  Future<List<servicios>> buscarServicios(String query) async {
    if (query.isEmpty) {
      return await getServicios(); // Si no hay query, devolver todos
    }

    if (query.length < 2) {
      throw Exception('Ingresa al menos 2 caracteres para buscar');
    }

    return await catalogoRepo.buscarServicios(query);
  }

  Future<servicios?> getServicioPorCodigo(String codigo) async {
    if (codigo.isEmpty) {
      throw Exception('El código no puede estar vacío');
    }

    final todosServicios = await catalogoRepo.getServicios();
    return todosServicios.firstWhereOrNull((obra) => obra.codigo == codigo);
  }

  Future<servicios?> getServicioPorDescripcion(String descripcion) async {
    if (descripcion.isEmpty) {
      throw Exception('La descripción no puede estar vacía');
    }

    final todosServicios = await catalogoRepo.getServicios();
    return todosServicios.firstWhereOrNull(
          (obra) => obra.descripcion.toLowerCase() == descripcion.toLowerCase(),
    );
  }

  // Para dropdowns en UI - formato optimizado
  Future<List<Map<String, dynamic>>> getServiciosParaDropdown() async {
    final servicios = await catalogoRepo.getServicios();

    return servicios.map((serv) => {
      'value': serv.codigo,  // ← Usamos el código como valor
      'label': '${serv.codigo} - ${serv.descripcion}',
      'object': serv, // Objeto completo por si se necesita
    }).toList();
  }

  // Buscar servicios que contengan texto en la descripción
  Future<List<servicios>> buscarServiciosPorDescripcion(String descripcion) async {
    if (descripcion.isEmpty) {
      return await getServicios();
    }

    if (descripcion.length < 2) {
      throw Exception('Ingresa al menos 2 caracteres para buscar');
    }

    final todosServicios = await catalogoRepo.getServicios();
    return todosServicios.where((serv) =>
        serv.descripcion.toLowerCase().contains(descripcion.toLowerCase())
    ).toList();
  }

  // Validar si un servicio existe
  Future<bool> existeServicio(String codigo) async {
    final servicio = await getServicioPorCodigo(codigo);
    return servicio != null;
  }

  // Validar si existe servicio por descripción exacta
  Future<bool> existeServicioPorDescripcion(String descripcion) async {
    final servicio = await getServicioPorDescripcion(descripcion);
    return servicio != null;
  }

  // Filtrar servicios válidos (con datos completos)
  Future<List<servicios>> getServiciosValidos() async {
    final todos = await catalogoRepo.getServicios();
    return todos.where((serv) => serv.esValido).toList();
  }

  // Obtener sugerencias para autocompletado
  Future<List<String>> getSugerenciasDescripciones() async {
    final servicios = await catalogoRepo.getServicios();
    return servicios.map((serv) => serv.descripcion).toList();
  }

  // Obtener sugerencias de códigos
  Future<List<String>> getSugerenciasCodigos() async {
    final servicios = await catalogoRepo.getServicios();
    return servicios.map((serv) => serv.codigo).toList();
  }

  // Validar formato de código (opcional)
  bool validarFormatoCodigo(String codigo) {
    if (codigo.isEmpty) return false;
    // Puedes agregar validaciones específicas según tu formato
    return codigo.length >= 1; // Mínimo 1 carácter
  }

// ================================== REPUESTOS =================================
  Future<List<repuestos>> getRepuestos() async {
    return await catalogoRepo.getRepuestos();
  }

  Future<List<repuestos>> buscarRepuestos(String query) async {
    if (query.isEmpty) {
      return await getRepuestos(); // Si no hay query, devolver todos
    }

    if (query.length < 2) {
      throw Exception('Ingresa al menos 2 caracteres para buscar');
    }

    return await catalogoRepo.buscarRepuestos(query);
  }

  Future<List<repuestos>> getRepuestosPorModelo(String modelo) async {
    if (modelo.isEmpty) {
      throw Exception('El modelo no puede estar vacío');
    }

    final todosRepuestos = await catalogoRepo.getRepuestos();
    return todosRepuestos.where((repuesto) =>
        repuesto.modelo.toLowerCase().contains(modelo.toLowerCase())
    ).toList();
  }

  Future<List<repuestos>> getRepuestosPorComponente(String componente) async {
    if (componente.isEmpty) {
      throw Exception('El componente no puede estar vacío');
    }

    final todosRepuestos = await catalogoRepo.getRepuestos();
    return todosRepuestos.where((repuesto) =>
        repuesto.componente.toLowerCase().contains(componente.toLowerCase())
    ).toList();
  }

  Future<repuestos?> getRepuestoExacto(String modelo, String componente) async {
    if (modelo.isEmpty || componente.isEmpty) {
      throw Exception('Modelo y componente son requeridos');
    }

    final todosRepuestos = await catalogoRepo.getRepuestos();
    return todosRepuestos.firstWhereOrNull((repuesto) =>
    repuesto.modelo.toLowerCase() == modelo.toLowerCase() &&
        repuesto.componente.toLowerCase() == componente.toLowerCase()
    );
  }

  // Para dropdowns en UI - formato optimizado
  Future<List<Map<String, dynamic>>> getRepuestosParaDropdown() async {
    final repuestos = await catalogoRepo.getRepuestos();

    return repuestos.map((rep) => {
      'value': '${rep.modelo}|${rep.componente}', // ← Clave compuesta
      'label': '${rep.modelo} - ${rep.componente} - \$${rep.ultimaCotizacion}',
      'object': rep, // Objeto completo por si se necesita
      'precio': rep.ultimaCotizacion, // Para mostrar precio
    }).toList();
  }

  // Buscar repuestos por rango de precio
  Future<List<repuestos>> getRepuestosPorRangoPrecio(double min, double max) async {
    if (min < 0 || max < 0 || min > max) {
      throw Exception('Rango de precio inválido');
    }

    final todosRepuestos = await catalogoRepo.getRepuestos();
    return todosRepuestos.where((repuesto) =>
    repuesto.ultimaCotizacion >= min && repuesto.ultimaCotizacion <= max
    ).toList();
  }

  // Buscar repuestos con precio mayor a
  Future<List<repuestos>> getRepuestosPrecioMayorA(double precio) async {
    if (precio < 0) {
      throw Exception('El precio no puede ser negativo');
    }

    final todosRepuestos = await catalogoRepo.getRepuestos();
    return todosRepuestos.where((repuesto) =>
    repuesto.ultimaCotizacion > precio
    ).toList();
  }

  // Buscar repuestos con precio menor a
  Future<List<repuestos>> getRepuestosPrecioMenorA(double precio) async {
    if (precio < 0) {
      throw Exception('El precio no puede ser negativo');
    }

    final todosRepuestos = await catalogoRepo.getRepuestos();
    return todosRepuestos.where((repuesto) =>
    repuesto.ultimaCotizacion < precio
    ).toList();
  }

  // Validar si un repuesto existe
  Future<bool> existeRepuesto(String modelo, String componente) async {
    final repuesto = await getRepuestoExacto(modelo, componente);
    return repuesto != null;
  }

  // Filtrar repuestos válidos (con datos completos)
  Future<List<repuestos>> getRepuestosValidos() async {
    final todos = await catalogoRepo.getRepuestos();
    return todos.where((rep) => rep.esValido).toList();
  }

  // Obtener sugerencias para autocompletado
  Future<List<String>> getSugerenciasModelos() async {
    final repuestos = await catalogoRepo.getRepuestos();
    return repuestos.map((rep) => rep.modelo).toSet().toList(); // Unique
  }

  Future<List<String>> getSugerenciasComponentes() async {
    final repuestos = await catalogoRepo.getRepuestos();
    return repuestos.map((rep) => rep.componente).toSet().toList(); // Unique
  }

  // Obtener precios estadísticos
  Future<Map<String, dynamic>> getEstadisticasPrecios() async {
    final repuestos = await catalogoRepo.getRepuestos();

    if (repuestos.isEmpty) {
      return {'promedio': 0.0, 'maximo': 0.0, 'minimo': 0.0, 'total': 0};
    }

    final precios = repuestos.map((r) => r.ultimaCotizacion).toList();
    final promedio = precios.reduce((a, b) => a + b) / precios.length;
    final maximo = precios.reduce((a, b) => a > b ? a : b);
    final minimo = precios.reduce((a, b) => a < b ? a : b);

    return {
      'promedio': promedio,
      'maximo': maximo,
      'minimo': minimo,
      'total': repuestos.length,
    };
  }

  // Obtener repuestos ordenados por precio
  Future<List<repuestos>> getRepuestosOrdenadosPorPrecio({bool ascendente = true}) async {
    final repuestos = await catalogoRepo.getRepuestos();
    repuestos.sort((a, b) => ascendente
        ? a.ultimaCotizacion.compareTo(b.ultimaCotizacion)
        : b.ultimaCotizacion.compareTo(a.ultimaCotizacion)
    );
    return repuestos;
  }

  // Obtener repuestos ordenados por modelo
  Future<List<repuestos>> getRepuestosOrdenadosPorModelo({bool ascendente = true}) async {
    final repuestos = await catalogoRepo.getRepuestos();
    repuestos.sort((a, b) => ascendente
        ? a.modelo.compareTo(b.modelo)
        : b.modelo.compareTo(a.modelo)
    );
    return repuestos;
  }

  // Validar formato de precio
  bool validarPrecio(double precio) {
    return precio >= 0;
  }

  // Obtener repuestos únicos por modelo (sin duplicados)
  Future<List<repuestos>> getModelosUnicos() async {
    final listaRepuestos = await catalogoRepo.getRepuestos(); // ← Cambiar nombre
    final modelosUnicos = <String, repuestos>{}; // ← Ahora sí es el tipo

    for (final repuesto in listaRepuestos) { // ← Usar nuevo nombre
      if (!modelosUnicos.containsKey(repuesto.modelo)) {
        modelosUnicos[repuesto.modelo] = repuesto;
      }
    }

    return modelosUnicos.values.toList();
  }
}
