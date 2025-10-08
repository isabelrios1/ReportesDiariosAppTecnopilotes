import '../supabase_manager.dart';
import '../../schema/structs/reportes/reporte_combustible.dart';

// Importa otros tipos de reportes según necesites

class ReporteRepository {
  final SupabaseManager supabase;

  ReporteRepository(this.supabase);

  // === REPORTE COMBUSTIBLE ===
  Future<void> createReporteCombustible(ReporteCombustible reporte) async {
    try {
      await supabase.client
          .from('cambioCombustible') // ← Tu tabla específica
          .insert(reporte.toJson());
    } catch (e) {
      supabase.handleSupabaseError(e);
      rethrow;
    }
  }
}