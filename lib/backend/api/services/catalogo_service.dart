// lib/backend/api/services/catalogo_service.dart
import 'package:reportes_diarios/backend/schema/structs/empleado.dart';
import 'package:collection/collection.dart';
import '../../schema/structs/obras.dart';
import '../repositories/catalogo_repo.dart';
import '../../schema/structs/descripcion_trabajo.dart';

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
}
