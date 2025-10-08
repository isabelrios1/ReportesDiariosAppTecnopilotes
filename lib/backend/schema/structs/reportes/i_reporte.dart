abstract class Reporte {
  // === PROPIEDADES MÍNIMAS Y ESENCIALES ===
  int? get nro;           // Código del reporte
  DateTime get fecha;       // Fecha actual del reporte
  String get maquina;       // Nombre de la máquina

  // === ÚNICO MÉTODO COMÚN ===
  Map<String, dynamic> toJson();  // Para crear en la base de datos
}