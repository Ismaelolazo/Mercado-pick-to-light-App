import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

class ArSupermercado extends StatefulWidget {
  final Map<String, dynamic> producto;
  const ArSupermercado({super.key, required this.producto});

  @override
  State<ArSupermercado> createState() => _ArSupermercadoState();
}

class _ArSupermercadoState extends State<ArSupermercado> {
  ArCoreController? coreController;

  @override
  void dispose() {
    coreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Supermercado AR"),
        centerTitle: true,
      ),
      body: ArCoreView(
        onArCoreViewCreated: _onArCoreViewCreated,
        enableUpdateListener: false,
      ),
    );
  }

  Future<void> _onArCoreViewCreated(ArCoreController controller) async {
    coreController = controller;

    // Cargar el archivo mapa.json
    final data = await rootBundle.loadString('assets/data/mapa.json');
    final jsonData = jsonDecode(data);
    final gondolas = List<Map<String, dynamic>>.from(jsonData["mapa"]["gondolas"]);
    final zonas = List<Map<String, dynamic>>.from(jsonData["mapa"]["zonas"]);

    // Mostrar todas las góndolas
    for (var g in gondolas) {
      _displayGondola(g);
    }

    // Escala usada
    final scale = 1.0;

    // Obtener punto de entrada
    final entrada = zonas.firstWhere((z) => z["id"] == "entrada");
    final double entradaX = entrada["x"];
    final double entradaY = entrada["y"];

    // Usar el producto seleccionado como destino
    final producto = widget.producto;
    final destinoX = producto["x"];
    final destinoY = producto["y"];

    // Calcular ruta tipo L
    final ruta = calcularRutaL(
      entradaX,
      entradaY,
      destinoX,
      destinoY,
      scale,
    );

    // Dibujar la ruta
    drawRoute(ruta);
  }

  void _displayGondola(Map<String, dynamic> g) {
    final double x = g["x"];
    final double y = g["y"];
    final String id = g["id"];

    final material = ArCoreMaterial(
      color: Colors.brown.shade400,
      metallic: 0.3,
    );

    // Aplicar escala y altura
    final scale = 1.0; // cada unidad del JSON representa 1 metro real
    final alto = 1.5;

    final cube = ArCoreCube(
      materials: [material],
      size: vector.Vector3(0.4, alto, 0.6),
    );

    final node = ArCoreNode(
      shape: cube,
      name: id,
      position: vector.Vector3(x * scale, alto / 2, -y * scale),
    );
    coreController?.addArCoreNode(node);

    final userMarker = ArCoreNode(
      shape: ArCoreSphere(
        radius: 0.05,
        materials: [ArCoreMaterial(color: Colors.blue)],
      ),
      position: vector.Vector3(0, 0.05, 0),
    );
    coreController?.addArCoreNode(userMarker);
  }

  List<vector.Vector3> calcularRutaL(double x0, double y0, double x1, double y1, double scale) {
    return [
      vector.Vector3(x0 * scale, 0.05, -y0 * scale),
      vector.Vector3(x1 * scale, 0.05, -y0 * scale),
      vector.Vector3(x1 * scale, 0.05, -y1 * scale),
    ];
  }

  void drawRoute(List<vector.Vector3> puntos) {
    final material = ArCoreMaterial(color: Colors.orangeAccent);

    for (var punto in puntos) {
      final sphere = ArCoreSphere(
        radius: 0.05,
        materials: [material],
      );

      final node = ArCoreNode(
        shape: sphere,
        position: punto,
      );

      coreController?.addArCoreNode(node);
    }
  }
}
