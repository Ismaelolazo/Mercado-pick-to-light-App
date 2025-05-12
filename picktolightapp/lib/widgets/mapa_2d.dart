import 'dart:convert';
import 'dart:ui'; // Import necesario para Rect
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picktolightapp/models/producto.dart';
import 'package:picktolightapp/services/firebase_service.dart';

class GondolaInfo {
  final String id;
  final Rect area;

  GondolaInfo(this.id, this.area);
}

class Mapa2DWidget extends StatefulWidget {
  final List<Producto> productos;
  final Producto? puntoInicio; // ✅ Nuevo parámetro para el punto de inicio

  const Mapa2DWidget({
    super.key,
    required this.productos,
    this.puntoInicio,
  });

  @override
  State<Mapa2DWidget> createState() => _Mapa2DWidgetState();
}

class _Mapa2DWidgetState extends State<Mapa2DWidget> {
  Map<String, dynamic>? mapaData;
  final List<GondolaInfo> gondolaAreas = []; // Lista para guardar las áreas de las góndolas

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
                  child: GestureDetector(
                    onTapUp: (details) {
                      final touchPosition = details.localPosition;
                      for (var g in gondolaAreas) {
                        if (g.area.contains(touchPosition)) {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text("Góndola ${g.id}"),
                              content: Text("Contiene: ${_productosDe(g.id)}"),
                            ),
                          );
                          break;
                        }
                      }
                    },
                    child: InteractiveViewer(
                      boundaryMargin: const EdgeInsets.all(20.0),
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Center(
                        child: SizedBox(
                          width: 800, // Ajusta el ancho según el tamaño del mapa
                          height: 800, // Ajusta la altura según el tamaño del mapa
                          child: CustomPaint(
                            painter: MapaPainter(
                              productos: widget.productos,
                              gondolas: List<Map<String, dynamic>>.from(mapaData!["gondolas"]),
                              estantes: List<Map<String, dynamic>>.from(mapaData!["estantes"]),
                              zonas: List<Map<String, dynamic>>.from(mapaData!["zonas"]),
                              gondolaAreas: gondolaAreas,
                              puntoInicio: widget.puntoInicio, // ✅ Pasa el punto de inicio
                            ),
                            size: Size.infinite,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ExpansionTile(
                    title: const Text("Leyenda del mapa"),
                    children: const [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12.0),
                        child: LeyendaMapa(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Compra completada"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onPressed: () async {
                      await FirebaseService.apagarTodasLasLuces();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Gracias por tu preferencia.")),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  String _productosDe(String gondolaId) {
    final productosEnGondola = widget.productos.where((p) => p.gondola == gondolaId).toList();
    if (productosEnGondola.isEmpty) return "Sin productos asignados";
    return productosEnGondola.map((p) => p.nombre).join(", ");
  }
}

class MapaPainter extends CustomPainter {
  final List<Producto> productos;
  final List<Map<String, dynamic>> gondolas;
  final List<Map<String, dynamic>> estantes;
  final List<Map<String, dynamic>> zonas;
  final List<GondolaInfo> gondolaAreas;
  final Producto? puntoInicio; // ✅ Nuevo parámetro para el punto de inicio

  MapaPainter({
    required this.productos,
    required this.gondolas,
    required this.estantes,
    required this.zonas,
    required this.gondolaAreas,
    this.puntoInicio,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scaleX = size.width / 8.0;
    final scaleY = size.height / 8.0;
    final Paint paint = Paint();

    // 🟫 Góndolas
    for (var g in gondolas) {
      final String id = g['id'];
      final x = g['x'] * scaleX;
      final y = g['y'] * scaleY;
      paint.color = Colors.brown.shade400;

      final int fila = g['fila'] ?? 0;
      final bool isFilaDe6 = fila <= 3;

      final double width = isFilaDe6 ? 0.6 * scaleX : 0.4 * scaleX;
      final double height = isFilaDe6 ? 0.4 * scaleY : 0.8 * scaleY;

      final rect = Rect.fromCenter(center: Offset(x, y), width: width, height: height);
      canvas.drawRect(rect, paint);

      gondolaAreas.add(GondolaInfo(id, rect));
    }

    // ⬛ Estantes empotrados
    for (var e in estantes) {
      final x = e['x'] * scaleX;
      final y = e['y'] * scaleY;
      paint.color = Colors.grey.shade800;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 0.3 * scaleX, height: 1.0 * scaleY), paint);
    }

    // 🟥 Cajas
    for (var z in zonas.where((z) => z['id'].toString().startsWith("caja"))) {
      final x = z['x'] * scaleX;
      final y = z['y'] * scaleY;
      paint.color = Colors.red;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 0.4 * scaleX, height: 0.5 * scaleY), paint);
    }

    // 🟩 Entrada y casilleros
    for (var z in zonas.where((z) => z['id'] == "entrada" || z['id'] == "casilleros")) {
      final x = z['x'] * scaleX;
      final y = z['y'] * scaleY;
      paint.color = Colors.green;
      canvas.drawRect(Rect.fromCenter(center: Offset(x, y), width: 0.6 * scaleX, height: 0.6 * scaleY), paint);
    }

    // 🟠 Productos seleccionados
    final productosOrdenados = [...productos];
    productosOrdenados.sort((a, b) => b.y.compareTo(a.y));

    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    for (int i = 0; i < productosOrdenados.length; i++) {
      final p = productosOrdenados[i];
      final x = p.x * scaleX;
      final y = p.y * scaleY;

      paint.color = Colors.orange;
      canvas.drawCircle(Offset(x, y), 10, paint);

      textPainter.text = TextSpan(
        text: "${i + 1}",
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 6, y - 8));
    }

    // 🟢 Punto de inicio
    if (puntoInicio != null) {
      final double x = puntoInicio!.x * scaleX;
      final double y = puntoInicio!.y * scaleY;

      // Dibuja el punto verde
      paint.color = Colors.green;
      canvas.drawCircle(Offset(x, y), 10, paint);

      // Dibuja el texto flotante
      textPainter.text = const TextSpan(
        text: "Aquí estás",
        style: TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - 24));
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
        item(Colors.grey.shade800, "Estante empotrado"),
        item(Colors.green, "Entrada/Casilleros"),
        item(Colors.red, "Caja"),
        item(Colors.orange, "Producto seleccionado", isCircle: true),
      ],
    );
  }
}
