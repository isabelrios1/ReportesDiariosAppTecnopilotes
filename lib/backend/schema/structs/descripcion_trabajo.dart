// lib/backend/schema/structs/descripcion_trabajo.dart

class DescripcionTrabajo {
  final String codigo;    // Código identificador (ej: "TRAB-001")
  final String detalle;   // Descripción detallada del trabajo

  DescripcionTrabajo({
    required this.codigo,
    required this.detalle
  });

  // Conversión desde JSON (lo que viene de Supabase)
  factory DescripcionTrabajo.fromJson(Map<String, dynamic> json) {
    return DescripcionTrabajo(
      codigo: json['codigo'] as String,
      detalle: json['detalle'] as String,
    );
  }

  // Conversión a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'detalle': detalle,
    };
  }

  // Validaciones básicas
  bool get esValido => codigo.isNotEmpty && detalle.isNotEmpty;

  // Para mostrar en UI (Dropdowns, Listas)
  @override
  String toString() {
    return '$codigo - $detalle';
  }

  // Comparación para igualdad (útil para tests)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DescripcionTrabajo &&
        other.codigo == codigo &&
        other.detalle == detalle;
  }

  @override
  int get hashCode {
    return Object.hash(codigo, detalle);
  }
}