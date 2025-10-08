import '../supabase_manager.dart';
import '../../schema/structs/catalogo/maquina.dart';
import '../../schema/structs/catalogo/obras.dart';
import '../../schema/structs/catalogo/repuestos.dart';
import '../../schema/structs/catalogo/servicio.dart';
import '../../schema/structs/catalogo/descripcion_trabajo.dart';


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
//================================= MAQUINAS =================================
  Future<List<Maquina>> getMaquinas() => _fetchMaquinas();
  Future<List<Maquina>> getMaquinasActivas() => _fetchMaquinas(estado: 'operativa');
  Future<List<Maquina>> getMaquinasPorTipo(String tipo) => _fetchMaquinas(tipo: tipo);
  Future<List<Maquina>> getMaquinasPorEstado(String estado) => _fetchMaquinas(estado: estado);

  Future<List<Maquina>> _fetchMaquinas({String? tipo, String? estado}) async {
    try {
      var query = supabase.client.from('maquinaria').select('*');

      if (tipo != null) query = query.eq('tipo', tipo);
      if (estado != null) query = query.eq('estado', estado);

      final data = await query.order('nombre');
      return data.map<Maquina>((json) => Maquina.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  // --- CONSULTAS ESPECÍFICAS ---
  Future<List<Maquina>> getMaquinasEnObra(String obraId) async {
    try {
      final data = await supabase.client
          .from('maquinaria')
          .select('*')
          .eq('obraActual', obraId) // ← Corregido: sin ->>
          .order('nombre');

      return data.map<Maquina>((json) => Maquina.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<List<Maquina>> getMaquinasConObra() async {
    try {
      final data = await supabase.client
          .from('maquinaria') // ← Corregido: era 'maquinas'
          .select('*, obras:obraActual(id, nombre)')
          .order('nombre');

      return data.map<Maquina>((json) {
        final maquina = Maquina.fromJson(json);
        if (json['obras'] != null) {
          maquina.cargarObraCompleta(obras.fromJson(json['obras']));
        }
        return maquina;
      }).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<Maquina?> getMaquinaPorCodigo(String codigo) async {
    try {
      final data = await supabase.client
          .from('maquinaria')
          .select('*')
          .eq('codigo', codigo)
          .single();

      return Maquina.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<Maquina>> buscarMaquinas(String query) async {
    try {
      final data = await supabase.client
          .from('maquinaria')
          .select('*')
          .or('codigo.ilike.%$query%,nombre.ilike.%$query%,tipo.ilike.%$query%')
          .order('nombre');

      return data.map<Maquina>((json) => Maquina.fromJson(json)).toList();
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  // --- ACTUALIZACIONES ---
  Future<void> _actualizarCampo(String codigo, String campo, dynamic valor) async {
    try {
      await supabase.client
          .from('maquinaria')
          .update({campo: valor})
          .eq('codigo', codigo);
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }

  Future<void> actualizarKilometraje(String codigo, double valor) =>
      _actualizarCampo(codigo, 'kilometraje', valor);

  Future<void> actualizarHorometro(String codigo, double valor) =>
      _actualizarCampo(codigo, 'horometro', valor);

  Future<void> actualizarEstado(String codigo, String estado) =>
      _actualizarCampo(codigo, 'estado', estado);

  Future<void> actualizarObraActual(String codigo, int? obraId) =>
      _actualizarCampo(codigo, 'obraActual', obraId);

  // --- VERIFICACIONES ---
  Future<bool> existeMaquina(String codigo) async {
    try {
      await supabase.client
          .from('maquinaria')
          .select('codigo')
          .eq('codigo', codigo)
          .single();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> maquinaEstaOperativa(String codigo) async {
    try {
      final data = await supabase.client
          .from('maquinaria')
          .select('estado')
          .eq('codigo', codigo)
          .single();
      return data['estado'] == 'operativa';
    } catch (e) {
      return false;
    }
  }
}
