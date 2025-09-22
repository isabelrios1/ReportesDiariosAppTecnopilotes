class servicios {
  final String codigo;    // Código identificador (ej: "TRAB-001")
  final String descripcion;
  // Descripción detallada del trabajo

  servicios({
    required this.codigo,
    required this.descripcion
  });

  // Conversión desde JSON (lo que viene de Supabase)
  factory servicios.fromJson(Map<String, dynamic> json) {
    return servicios(
      codigo: (json['codigo'] ?? '').toString(), // ← Manejar null
      descripcion: (json['descripcion'] ?? '').toString(),
    );
  }

  // Conversión a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'descripcion': descripcion
    };
  }

  // Validaciones básicas
  bool get esValido => codigo.isNotEmpty != 0 && descripcion.isNotEmpty;

  // Para mostrar en UI (Dropdowns, Listas)
  @override
  String toString() {
    return '$codigo - $descripcion';
  }

  // Comparación para igualdad (útil para tests)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is servicios &&
        other.codigo == codigo;
  }

  @override
  int get hashCode {
    return Object.hash(codigo, descripcion);
  }
}
