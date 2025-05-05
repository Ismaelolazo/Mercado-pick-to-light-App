import 'package:flutter/material.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:picktolightapp/models/producto.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'dart:convert';
import 'package:flutter/services.dart';

class ArRutaPasoAPaso extends StatefulWidget {
  final List<Producto> productos;
  final Producto inicio;

  const ArRutaPasoAPaso({super.key, required this.productos, required this.inicio});

  @override
  State<ArRutaPasoAPaso> createState() => _ArRutaPasoAPasoState();
}

class _ArRutaPasoAPasoState extends State<ArRutaPasoAPaso> {
  ArCoreController? controller;
  int pasoActual = 0;
  List<Map<String, dynamic>> zonas = [];
  static const double escala = 1.0;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    cargarZonas();
  }

  Future<void> cargarZonas() async {
    final data = await rootBundle.loadString('assets/data/mapa.json');
    final jsonData = jsonDecode(data);
    zonas = List<Map<String, dynamic>>.from(jsonData["mapa"]["zonas"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ruta paso a paso")),
      body: Stack(
        children: [
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableUpdateListener: false,
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ElevatedButton(
              onPressed: mostrarSiguientePaso,
              child: const Text("Siguiente paso"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onArCoreViewCreated(ArCoreController c) async {
    controller = c;
    pasoActual = 0;
    mostrarSiguientePaso();
  }

  void mostrarSiguientePaso() {
    if (pasoActual >= widget.productos.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Ruta completada!")),
      );
      return;
    }

    controller?.removeNode(nodeName: "ruta"); // elimina paso anterior

    final entrada = zonas.firstWhere((z) => z["id"] == "entrada");
    double fromX = entrada["x"];
    double fromY = entrada["y"];

    if (pasoActual > 0) {
      final anterior = widget.productos[pasoActual - 1];
      fromX = anterior.x;
      fromY = anterior.y;
    }

    final destino = widget.productos[pasoActual];
    final ruta = calcularRutaL(fromX, fromY, destino.x, destino.y, escala);
    drawRuta(ruta);
    pasoActual++;
  }

  List<vector.Vector3> calcularRutaL(double x0, double y0, double x1, double y1, double s) {
    return [
      vector.Vector3(x0 * s, 0.05, -y0 * s),
      vector.Vector3(x1 * s, 0.05, -y0 * s),
      vector.Vector3(x1 * s, 0.05, -y1 * s),
    ];
  }

  void drawRuta(List<vector.Vector3> puntos) {
    final material = ArCoreMaterial(color: Colors.orangeAccent);

    for (int i = 0; i < puntos.length; i++) {
      final sphere = ArCoreSphere(radius: 0.05, materials: [material]);
      final node = ArCoreNode(
        shape: sphere,
        position: puntos[i],
        name: "ruta", // todos con mismo nombre, se borran juntos
      );
      controller?.addArCoreNode(node);
    }
  }
}
