import '../supabase_manager.dart';
import '../../schema/structs/maquina.dart';
import '../../schema/structs/empleado.dart';
import '../../schema/structs/obras.dart';
import '../../schema/structs/repuestos.dart';
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


//================================= SERVICIOS =================================

  Future<List<servicios>> getServicios() async {
    try {
      final data = await supabase.client
          .from('servicios')
          .select('codigo, descripcion')  // ← Solo los campos que necesitas
          .order('codigo');

      return data.map<servicios>((json) =>
          servicios.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<List<servicios>> buscarServicios(String query) async {
    try {
      final data = await supabase.client
          .from('servicios')
          .select('codigo, descripcion')
          .or('codigo.ilike.%$query%,descripcion.ilike.%$query%')
          .order('codigo');

      return data.map<servicios>((json) =>
          servicios.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }


//================================= REPUESTOS =================================

  Future<List<repuestos>> getRepuestos() async {
    try {
      final data = await supabase.client
          .from('repuestos')
          .select('modelo, componente, ultimaCotizacion')  // ← Solo los campos que necesitas
          .order('modelo');

      return data.map<repuestos>((json) =>
          repuestos.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<List<repuestos>> buscarRepuestos(String query) async {
    try {
      // Verificar si la query es numérica (para buscar por precio)
      final esNumerico = double.tryParse(query) != null;

      if (esNumerico) {
        // Buscar por precio exacto si la query es numérica
        final precio = double.parse(query);
        final data = await supabase.client
            .from('repuestos')
            .select('modelo, componente, ultimaCotizacion')
            .eq('ultimaCotizacion', precio) // ← Usar eq para números
            .order('modelo');

        return data.map<repuestos>((json) =>
            repuestos.fromJson(json)).toList();
      } else {
        // Buscar por texto si no es numérico
        final data = await supabase.client
            .from('repuestos')
            .select('modelo, componente, ultimaCotizacion')
            .or('modelo.ilike.%$query%,componente.ilike.%$query%')
            .order('modelo');

        return data.map<repuestos>((json) =>
            repuestos.fromJson(json)).toList();
      }
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }
}