// lib/backend/schema/structs/reporte_combustible.dart
import 'i_reporte.dart';

class ReporteCombustible implements Reporte {
  @override
  final int? nro;
  @override
  final DateTime fecha;
  @override
  final String maquina;

  final double litros;
  final double costo;
  final String tipoCombustible;

  ReporteCombustible({
    required this.fecha,
    required this.maquina,
    required this.litros,
    required this.costo,
    required this.tipoCombustible,
    this.nro,
  }) {
    // Validaciones básicas en el constructor
    _validarDatos();
  }

  void _validarDatos() {
    if (litros <= 0.0) {
      throw ArgumentError('Los litros deben ser mayor a 0');
    }
    if (costo <= 0.0) {
      throw ArgumentError('El costo debe ser mayor a 0');
    }
    if (maquina.isEmpty) {
      throw ArgumentError('La máquina es requerida');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final json = {
      'fecha': fecha.toIso8601String(),
      'maquina': maquina,
      'litros': litros,
      'costo': costo,
      'tipo_combustible': tipoCombustible,
    };

    // Solo incluir nro si fue proporcionado
    if (nro != null) {
      json['nro'] = nro!;
    }

    return json;
  }

  factory ReporteCombustible.fromJson(Map<String, dynamic> json) {
    return ReporteCombustible(
      nro: json['nro'] as int?,
      fecha: DateTime.parse(json['fecha']),
      maquina: json['maquina'],
      litros: (json['litros'] as num).toDouble(),
      costo: (json['costo'] as num).toDouble(),
      tipoCombustible: json['tipo_combustible'],
    );
  }
}