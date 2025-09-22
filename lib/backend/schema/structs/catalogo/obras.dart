// lib/backend/schema/structs/descripcion_trabajo.dart

class obras {
  final int id;    // Código identificador (ej: "TRAB-001")
  final String nombre;
  // Descripción detallada del trabajo

  obras({
    required this.id,
    required this.nombre
  });

  // Conversión desde JSON (lo que viene de Supabase)
  factory obras.fromJson(Map<String, dynamic> json) {
    return obras(
      id: (json['id'] ?? '').toInt(), // ← Manejar null
      nombre: (json['nombre'] ?? '').toString(),
    );
  }

  // Conversión a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre
    };
  }

  // Validaciones básicas
  bool get esValido => id != 0 && nombre.isNotEmpty;

  // Para mostrar en UI (Dropdowns, Listas)
  @override
  String toString() {
    return '$id - $nombre';
  }

  // Comparación para igualdad (útil para tests)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is obras &&
        other.id == id;
  }

  @override
  int get hashCode {
    return Object.hash(id, nombre);
  }
}
