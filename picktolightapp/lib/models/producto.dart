class Producto {
  final String id;
  final String nombre;
  final double x;
  final double y;
  final String? qr;       // Opcional, para navegación con QR
  final String? gondola;  // Opcional, para activar LEDs

  Producto({
    required this.id,
    required this.nombre,
    required this.x,
    required this.y,
    this.qr,
    this.gondola,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      qr: json['qr'] as String?,
      gondola: json['gondola'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "nombre": nombre,
    "x": x,
    "y": y,
    if (qr != null) "qr": qr,
    if (gondola != null) "gondola": gondola,
  };
}
