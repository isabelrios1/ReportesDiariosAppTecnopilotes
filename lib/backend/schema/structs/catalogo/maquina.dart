// lib/backend/schema/structs/maquina.dart
import 'obras.dart'; // Importar la clase Obra
class Maquina {
  final String codigo;
  final String nombre;
  final double kilometraje;
  final double horometro;
  final String tipo;
  final String propietario;
  final String combustible;
  final String estado;
  final int? obraActualId;
  final double tipoCambio;
  obras? _obraCompleta;

  Maquina({
    required this.codigo,
    required this.nombre,
    required this.kilometraje,
    required this.horometro,
    required this.tipo,
    required this.propietario,
    required this.combustible,
    required this.estado,
    this.obraActualId,
    required this.tipoCambio,
  });

  obras? get obraActual => _obraCompleta;
  void cargarObraCompleta(obras obra) => _obraCompleta = obra;

  // --- SERIALIZACIÓN ---
  factory Maquina.fromJson(Map<String, dynamic> json) {
    return Maquina(
      codigo: json['codigo']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      kilometraje: (json['kilometraje'] ?? 0.0).toDouble(),
      horometro: (json['horometro'] ?? 0.0).toDouble(),
      tipo: json['tipo']?.toString() ?? '',
      propietario: json['propietario']?.toString() ?? '',
      combustible: json['combustible']?.toString() ?? '',
      estado: json['estado']?.toString() ?? '',
      obraActualId: _parseObraId(json['obraActual']),
      tipoCambio: (json['tipoCambio'] ?? 1.0).toDouble(),
    );
  }

  static int? _parseObraId(dynamic obraData) {
    if (obraData == null) return null;
    if (obraData is int) return obraData;
    if (obraData is String) return int.tryParse(obraData);
    return null;
  }

  Map<String, dynamic> toJson() => {
    'codigo': codigo,
    'nombre': nombre,
    'kilometraje': kilometraje,
    'horometro': horometro,
    'tipo': tipo,
    'propietario': propietario,
    'combustible': combustible,
    'estado': estado,
    'obraActual': obraActualId,
    'tipoCambio': tipoCambio,
  };

  // --- VALIDACIONES Y PROPIEDADES ---
  bool get esValido => codigo.isNotEmpty && nombre.isNotEmpty;
  bool get tieneObraAsignada => obraActualId != null;
  bool get estaOperativa => estado.toLowerCase() == 'operativa';
  double get costoPorHora => horometro * tipoCambio;

  // --- UI/UX ---
  @override
  String toString() => '$codigo - $nombre${obraActual != null ? ' (${obraActual!.nombre})' : ''}';

  String get infoResumida => '$nombre - $tipo - $estado';

  String get infoDetallada => '''
Código: $codigo
Nombre: $nombre
Kilometraje: $kilometraje km
Horómetro: $horometro hrs
Tipo: $tipo
Propietario: $propietario
Combustible: $combustible
Estado: $estado
Obra: ${obraActual?.nombre ?? 'No asignada'}
Tipo Cambio: $tipoCambio
''';

  // --- EQUALITY & COPY ---
  @override bool operator ==(Object other) => identical(this, other) || (other is Maquina && other.codigo == codigo);
  @override int get hashCode => codigo.hashCode;

  Maquina copyWith({
    String? codigo, double? kilometraje, double? horometro, String? tipo,
    String? nombre, String? propietario, String? combustible, String? estado,
    int? obraActualId, double? tipoCambio,
  }) => Maquina(
    codigo: codigo ?? this.codigo,
    nombre: nombre ?? this.nombre,
    kilometraje: kilometraje ?? this.kilometraje,
    horometro: horometro ?? this.horometro,
    tipo: tipo ?? this.tipo,
    propietario: propietario ?? this.propietario,
    combustible: combustible ?? this.combustible,
    estado: estado ?? this.estado,
    obraActualId: obraActualId ?? this.obraActualId,
    tipoCambio: tipoCambio ?? this.tipoCambio,
  );

  Maquina reiniciarContadores() => copyWith(kilometraje: 0.0, horometro: 0.0);
}