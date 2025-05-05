class Producto {
  final String id;
  final String nombre;
  final double x;
  final double y;
  final String? qr; // ← permite nulo

  Producto({
    required this.id,
    required this.nombre,
    required this.x,
    required this.y,
    this.qr,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      id: json['id'],
      nombre: json['nombre'],
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      qr: json['qr'] as String?, // ← seguro para valores nulos
    );
  }
}
