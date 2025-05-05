import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picktolightapp/models/producto.dart';

class Mapa2DWidget extends StatelessWidget {
  final List<Producto> productos;

  const Mapa2DWidget({super.key, required this.productos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa del supermercado")),
      body: FutureBuilder(
        future: rootBundle.loadString('assets/data/mapa.json'),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final data = jsonDecode(snapshot.data as String);
          final gondolas = List<Map<String, dynamic>>.from(data["mapa"]["gondolas"]);
          final zonas = List<Map<String, dynamic>>.from(data["mapa"]["zonas"]);
          final entrada = zonas.firstWhere((z) => z["id"] == "entrada");

          return CustomPaint(
            painter: SupermercadoPainter(
              gondolas: gondolas,
              productos: productos,
              entrada: entrada,
            ),
            child: Container(),
          );
        },
      ),
    );
  }
}

class SupermercadoPainter extends CustomPainter {
  final List<Map<String, dynamic>> gondolas;
  final List<Producto> productos;
  final Map<String, dynamic> entrada;

  SupermercadoPainter({
    required this.gondolas,
    required this.productos,
    required this.entrada,
  });

  static const double escala = 50; // 1 metro = 50 px

  @override
  void paint(Canvas canvas, Size size) {
    final paintGondola = Paint()..color = Colors.brown;
    final paintProducto = Paint()..color = Colors.orange;
    final paintEntrada = Paint()..color = Colors.blue;

    // Dibujar góndolas
    for (var g in gondolas) {
      final x = g["x"] * escala;
      final y = g["y"] * escala;
      canvas.drawRect(Rect.fromLTWH(x - 10, y - 10, 20, 20), paintGondola);
    }

    // Dibujar productos
    for (var p in productos) {
      final x = p.x * escala;
      final y = p.y * escala;
      canvas.drawCircle(Offset(x, y), 6, paintProducto);
    }

    // Dibujar entrada
    final ex = entrada["x"] * escala;
    final ey = entrada["y"] * escala;
    canvas.drawCircle(Offset(ex, ey), 8, paintEntrada);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
