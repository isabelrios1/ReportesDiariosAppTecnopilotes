import '../../schema/structs/reportes/reporte_combustible.dart';
import '../repositories/reportes_repo.dart';

class ReporteService {
  final ReporteRepository reporteRepo;

  ReporteService(this.reporteRepo);

  Future<void> crearReporteCombustible({
    required String maquina,
    required double litros,
    required double costo,
    required String tipoCombustible,
  }) async {
    final reporte = ReporteCombustible(
      fecha: DateTime.now(),
      maquina: maquina,
      litros: litros,
      costo: costo,
      tipoCombustible: tipoCombustible,
      // nro: null ← No se proporciona, lo genera Supabase
    );

    await reporteRepo.createReporteCombustible(reporte);
  }
}