import '../supabase_manager.dart';
import '../../schema/structs/maquina.dart';
import '../../schema/structs/empleado.dart';
import '../../schema/structs/obras.dart';
import '../../schema/structs/repuesto.dart';
import '../../schema/structs/servicio.dart';
import '../../schema/structs/descripcion_trabajo.dart';


class CatalogoRepository {
  final SupabaseManager supabase;

  CatalogoRepository(this.supabase);


  //================================= DESCRIPCION TRABAJOS =================================

  Future<List<DescripcionTrabajo>> getDescripcionesTrabajo() async {
    try {
      final data = await supabase.client
          .from('descripcionTrabajo')
          .select('codigo, detalle')  // ← Solo los campos que necesitas
          .order('codigo');

      return data.map<DescripcionTrabajo>((json) =>
          DescripcionTrabajo.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<List<DescripcionTrabajo>> buscarDescripcionesTrabajo(String query) async {
    try {
      final data = await supabase.client
          .from('descripcionTrabajo')
          .select('codigo, detalle')
          .or('codigo.ilike.%$query%,detalle.ilike.%$query%')
          .order('codigo');

      return data.map<DescripcionTrabajo>((json) =>
          DescripcionTrabajo.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<DescripcionTrabajo?> getDescripcionTrabajoPorCodigo(String codigo) async {
    try {
      final data = await supabase.client
          .from('descripcionTrabajo')
          .select('codigo, detalle')
          .eq('codigo', codigo)
          .single();

      return DescripcionTrabajo.fromJson(data);
    } catch (e) {
      // Si no encuentra, devuelve null (no error)
      return null;
    }
  }

  //================================= EMPLEADOS =================================

  Future<List<empleado>> getEmpleados() async {
    try {
      final data = await supabase.client
          .from('empleados')
          .select('ci, nombre, apellidoPaterno, apellidoMaterno')  // ← Solo los campos que necesitas
          .order('nombre');

      return data.map<empleado>((json) =>
          empleado.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<List<empleado>> buscarEmpleados(String query) async {
    try {
      final data = await supabase.client
          .from('empleados')
          .select('ci, nombre, apellidoPaterno, apellidoMaterno, rol, cargo')
          .or('ci.ilike.%$query%,nombre.ilike.%$query%, apellidoPaterno.ilike.%$query%, apellidoMaterno.ilike.%$query%, rol.ilike.%$query%, cargo.ilike.%$query%')
          .order('nombre');

      return data.map<empleado>((json) =>
          empleado.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  //================================= OBRAS =================================

  Future<List<obras>> getObras() async {
    try {
      final data = await supabase.client
          .from('obras')
          .select('id, nombre')  // ← Solo los campos que necesitas
          .order('nombre');

      return data.map<obras>((json) =>
          obras.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  // En CatalogoRepository - corregir el método buscarObras
  Future<List<obras>> buscarObras(String query) async {
    try {
      // Si la query es numérica, buscar por ID
      final esNumerico = int.tryParse(query) != null;

      if (esNumerico) {
        // Buscar por ID exacto si la query es numérica
        final data = await supabase.client
            .from('obras')
            .select('id, nombre')
            .eq('id', int.parse(query))  // ← Usar eq para números
            .order('nombre');

        return data.map<obras>((json) => obras.fromJson(json)).toList();
      } else {
        // Buscar por nombre si la query es texto
        final data = await supabase.client
            .from('obras')
            .select('id, nombre')
            .ilike('nombre', '%$query%')  // ← Solo en campo texto
            .order('nombre');

        return data.map<obras>((json) => obras.fromJson(json)).toList();
      }
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }
}