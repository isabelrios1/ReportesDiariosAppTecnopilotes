class empleado {
  final String ci;    // Código identificador (ej: "TRAB-001")
  final String nombre;
  final String apellidoPaterno;
  final String apellidoMaterno;
  final String rol;
  final String password;
  final String cargo;
  // Descripción detallada del trabajo

  empleado({
    required this.ci,
    required this.nombre,
    required this.apellidoPaterno,
    required this.apellidoMaterno,
    required this.rol,
    required this.password,
    required this.cargo
  });

  // Conversión desde JSON (lo que viene de Supabase)
  factory empleado.fromJson(Map<String, dynamic> json) {
    return empleado(
      ci: (json['ci'] ?? '').toString(), // ← Manejar null
      nombre: (json['nombre'] ?? '').toString(),
      apellidoPaterno: (json['apellidoPaterno'] ?? '').toString(),
      apellidoMaterno: (json['apellidoMaterno'] ?? '').toString(),
      rol: (json['rol'] ?? '').toString(),
      password: (json['password'] ?? '').toString(),
      cargo: (json['cargo'] ?? '').toString(),
    );
  }

  // Conversión a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'ci': ci,
      'nombre': nombre,
      'apellidoPaterno': apellidoPaterno,
      'apellidoMaterno': apellidoMaterno,
      'rol': rol,
      'password': password,
      'cargo': cargo
    };
  }

  // Validaciones básicas
  bool get esValido => ci.isNotEmpty && nombre.isNotEmpty && apellidoMaterno.isNotEmpty && apellidoPaterno.isNotEmpty && rol.isNotEmpty && password.isNotEmpty && cargo.isNotEmpty;

  // Para mostrar en UI (Dropdowns, Listas)
  @override
  String toString() {
    return '$ci - $nombre';
  }

  // Comparación para igualdad (útil para tests)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is empleado &&
        other.ci == ci;
  }

  @override
  int get hashCode {
    return Object.hash(ci, nombre, apellidoPaterno, apellidoMaterno, rol, password, cargo);
  }
}