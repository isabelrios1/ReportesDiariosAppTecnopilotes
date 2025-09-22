class repuestos {
  final String modelo;
  final String componente;
  final double ultimaCotizacion;
  // Descripción detallada del trabajo

  repuestos({
    required this.modelo,
    required this.componente,
    required this.ultimaCotizacion
  });

  // Conversión desde JSON (lo que viene de Supabase)
  factory repuestos.fromJson(Map<String, dynamic> json) {
    return repuestos(
      modelo: (json['modelo'] ?? '').toString(), // ← Manejar null
      componente: (json['componente'] ?? '').toString(),
      ultimaCotizacion: json['ultimaCotizacion'] != null
          ? double.tryParse(json['ultimaCotizacion'].toString()) ?? 0.0
          : 0.0,
    );
  }

  // Conversión a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'modelo': modelo,
      'componente': componente,
      'ultimaCotizacion': ultimaCotizacion
    };
  }

  // Validaciones básicas
  bool get esValido => modelo.isNotEmpty && componente.isNotEmpty;

  // Para mostrar en UI (Dropdowns, Listas)
  @override
  String toString() {
    return '$modelo - $componente';
  }

  // Comparación para igualdad (útil para tests)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is repuestos &&
        other.modelo == modelo;
  }

  @override
  int get hashCode {
    return Object.hash(modelo, componente, ultimaCotizacion);
  }
}
