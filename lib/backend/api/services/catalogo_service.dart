// lib/backend/api/services/catalogo_service.dart
import '../repositories/catalogo_repo.dart';
import '../../schema/structs/descripcion_trabajo.dart';

class CatalogoService {
  final CatalogoRepository catalogoRepo;

  CatalogoService(this.catalogoRepo);

  // === DESCRIPCIONES DE TRABAJO ===
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
}