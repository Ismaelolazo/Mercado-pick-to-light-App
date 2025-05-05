class Gondola {
  final String id;
  final double x;
  final double y;

  Gondola({required this.id, required this.x, required this.y});

  factory Gondola.fromJson(Map<String, dynamic> json) {
    return Gondola(
      id: json['id'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }
}

class Estante {
  final String id;
  final double x;
  final double y;

  Estante({required this.id, required this.x, required this.y});

  factory Estante.fromJson(Map<String, dynamic> json) {
    return Estante(
      id: json['id'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }
}

class Zona {
  final String id;
  final double x;
  final double y;

  Zona({required this.id, required this.x, required this.y});

  factory Zona.fromJson(Map<String, dynamic> json) {
    return Zona(
      id: json['id'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
    );
  }
}

class Mapa {
  final double ancho;
  final double alto;
  final List<Gondola> gondolas;
  final List<Estante> estantes;
  final List<Zona> zonas;

  Mapa({
    required this.ancho,
    required this.alto,
    required this.gondolas,
    required this.estantes,
    required this.zonas,
  });

  factory Mapa.fromJson(Map<String, dynamic> json) {
    final m = json['mapa'];
    return Mapa(
      ancho: m['ancho_m'].toDouble(),
      alto: m['alto_m'].toDouble(),
      gondolas: (m['gondolas'] as List).map((e) => Gondola.fromJson(e)).toList(),
      estantes: (m['estantes'] as List).map((e) => Estante.fromJson(e)).toList(),
      zonas: (m['zonas'] as List).map((e) => Zona.fromJson(e)).toList(),
    );
  }
}
