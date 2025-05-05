import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picktolightapp/models/producto.dart';

class Mapa2DWidget extends StatefulWidget {
  final List<Producto> productos;
  const Mapa2DWidget({super.key, required this.productos});

  @override
  State<Mapa2DWidget> createState() => _Mapa2DWidgetState();
}

class _Mapa2DWidgetState extends State<Mapa2DWidget> {
  Map<String, dynamic>? mapaData;

  @override
  void initState() {
    super.initState();
    cargarMapa();
  }

  Future<void> cargarMapa() async {
    final jsonStr = await rootBundle.loadString('assets/data/mapa.json');
    final jsonData = jsonDecode(jsonStr);
    setState(() {
      mapaData = jsonData["mapa"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mapa 2D del Supermercado")),
      body: mapaData == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: MapaPainter(
                        productos: widget.productos,
                        gondolas: List<Map<String, dynamic>>.from(mapaData!["gondolas"]),
                        estantes: List<Map<String, dynamic>>.from(mapaData!["estantes"]),
                        zonas: List<Map<String, dynamic>>.from(mapaData!["zonas"]),
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: LeyendaMapa(),
                ),
              ],
            ),
    );
  }
}

class MapaPainter extends CustomPainter {
  final List<Producto> productos;
  final List<Map<String, dynamic>> gondolas;
  final List<Map<String, dynamic>> estantes;
  final List<Map<String, dynamic>> zonas;

  MapaPainter({
    required this.productos,
    required this.gondolas,
    required this.estantes,
    required this.zonas,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 8.0;
    final scaleY = size.height / 8.0;

    final Paint paint = Paint();

    // 1. Dibujar góndolas
    for (var g in gondolas) {
      final x = g['x'] * scaleX;
      final y = g['y'] * scaleY;
      paint.color = Colors.brown.shade400;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 0.4 * scaleX, height: 0.6 * scaleY), paint);
    }

    // 2. Dibujar estantes empotrados
    for (var e in estantes) {
      final x = e['x'] * scaleX;
      final y = e['y'] * scaleY;
      paint.color = Colors.grey.shade700;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 0.3 * scaleX, height: 0.8 * scaleY), paint);
    }

    // 3. Dibujar zonas clave
    for (var z in zonas) {
      final x = z['x'] * scaleX;
      final y = z['y'] * scaleY;
      paint.color = {
        'entrada': Colors.blue,
        'recepcion': Colors.green,
        'caja_1': Colors.red,
        'baño': Colors.indigo
      }[z['id']] ?? Colors.black;
      canvas.drawCircle(Offset(x, y), 10, paint);
    }

    // 4. Dibujar productos seleccionados (con número)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < productos.length; i++) {
      final p = productos[i];
      final x = p.x * scaleX;
      final y = p.y * scaleY;

      // Punto
      paint.color = Colors.orange;
      canvas.drawCircle(Offset(x, y), 10, paint);

      // Número
      textPainter.text = TextSpan(
        text: "${i + 1}",
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 6, y - 8));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class LeyendaMapa extends StatelessWidget {
  const LeyendaMapa({super.key});

  Widget item(Color color, String label, {bool isCircle = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 18,
          margin: const EdgeInsets.only(right: 6),
          decoration: BoxDecoration(
            color: color,
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        item(Colors.brown.shade400, "Góndola"),
        item(Colors.grey.shade700, "Estante empotrado"),
        item(Colors.blue, "Entrada", isCircle: true),
        item(Colors.green, "Recepción", isCircle: true),
        item(Colors.red, "Caja", isCircle: true),
        item(Colors.indigo, "Baño", isCircle: true),
        item(Colors.orange, "Producto seleccionado", isCircle: true),
      ],
    );
  }
}
