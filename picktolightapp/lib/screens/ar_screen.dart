import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:arcore_flutter_plugin/arcore_flutter_plugin.dart';
import 'package:picktolightapp/services/firebase_service.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import '../models/producto.dart';

class ArSupermercado extends StatefulWidget {
  final List<Producto> productos;
  const ArSupermercado({super.key, required this.productos});

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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        icon: const Icon(Icons.power_settings_new),
        label: const Text("Compra completada"),
        onPressed: () async {
          await FirebaseService.apagarTodasLasLuces();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gracias por su preferencia.")),
          );
        },
      ),
    );
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    coreController = controller;

    // Activa la detección de toques en nodos
    coreController?.onNodeTap = _mostrarInfoGondola;

    _crearEscenarioAR(); // Inicializa el escenario AR solo una vez
  }

  void _mostrarInfoGondola(String nodeName) {
    // Busca el producto asociado a la góndola tocada
    final producto = widget.productos.firstWhere(
      (p) => p.gondola == nodeName,
      orElse: () => Producto(id: nodeName, nombre: "Sin producto", x: 0, y: 0),
    );

    // Muestra un AlertDialog con la información de la góndola
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Góndola: ${nodeName.toUpperCase()}"),
        content: Text("Producto: ${producto.nombre}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cerrar"),
          ),
        ],
      ),
    );
  }

  void _crearEscenarioAR() async {
    const offsetX = -1.0; // Desplaza hacia la izquierda del usuario
    const offsetZ = -1.0; // Frente al usuario
    const escala = 0.25;  // Escala ajustada
    const espacio = 0.05; // Espacio adicional entre bloques

    // Carga el archivo mapa.json
    final String jsonStr = await rootBundle.loadString('assets/data/mapa.json');
    final data = jsonDecode(jsonStr);
    final gondolas = List<Map<String, dynamic>>.from(data['mapa']['gondolas']);

    // Extrae los IDs de góndolas seleccionadas
    final idsSeleccionados = widget.productos.map((p) => p.gondola).toSet();

    // Genera todas las góndolas
    for (final g in gondolas) {
      final String id = g['id'];
      final double x = g['x'] * (escala + espacio) + offsetX;
      final double z = -g['y'] * (escala + espacio) + offsetZ;

      final isSeleccionado = idsSeleccionados.contains(id);

      final material = ArCoreMaterial(
        color: isSeleccionado ? Colors.orange : Colors.brown.shade400,
        metallic: 0.2,
        reflectance: 0.1,
      );

      final cube = ArCoreCube(
        materials: [material],
        size: vector.Vector3(0.2, 0.4, 0.15), // Tamaño más grande
      );

      final node = ArCoreNode(
        name: id,
        shape: cube,
        position: vector.Vector3(x, 0.2, z), // Mitad de la altura
      );

      coreController?.addArCoreNode(node);

      // Si la góndola está seleccionada, dibuja una ruta en forma de "L"
      if (isSeleccionado) {
        final origen = vector.Vector3(0.0, 0.125, 0.0); // Frente del usuario
        final destino = vector.Vector3(x, 0.2, z);
        _dibujarRutaEnL(origen, destino);
      }
    }
  }

  void _dibujarRutaEnL(vector.Vector3 inicio, vector.Vector3 destino) {
    // Punto intermedio donde la ruta dobla
    final intermedio = vector.Vector3(destino.x, inicio.y, inicio.z);

    // Dibuja la línea horizontal y luego la vertical
    _dibujarLineaPunteada(inicio, intermedio);
    _dibujarLineaPunteada(intermedio, destino);
  }

  void _dibujarLineaPunteada(vector.Vector3 inicio, vector.Vector3 fin) {
    const pasos = 10; // Número de puntos en la línea
    for (int i = 0; i <= pasos; i++) {
      final t = i / pasos.toDouble();
      final x = inicio.x + (fin.x - inicio.x) * t;
      final y = inicio.y + (fin.y - inicio.y) * t;
      final z = inicio.z + (fin.z - inicio.z) * t;

      final esfera = ArCoreSphere(
        radius: 0.01, // Tamaño de cada punto
        materials: [ArCoreMaterial(color: Colors.orangeAccent)],
      );

      final nodo = ArCoreNode(
        shape: esfera,
        position: vector.Vector3(x, y, z),
      );

      coreController?.addArCoreNode(nodo);
    }
  }
}
