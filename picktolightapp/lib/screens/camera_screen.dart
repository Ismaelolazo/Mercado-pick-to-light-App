import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'ar_screen.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  final List<String> productos;

  const CameraScreen({Key? key, required this.cameras, required this.productos}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  bool _isCameraReady = false;

  // Simulación de puntos de destino en pantalla
  final Map<String, Offset> puntosProducto = {
    'Leche': Offset(0.3, 0.2),
    'Pan': Offset(0.6, 0.4),
    'Manzana': Offset(0.4, 0.6),
    'Yogurt': Offset(0.2, 0.7),
    'Arroz': Offset(0.7, 0.8),
  };

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[0], ResolutionPreset.medium);
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: _isCameraReady
          ? Stack(
              children: [
                // Vista de cámara
                CameraPreview(_controller),

                // Superposición de puntos
                ...widget.productos.map((producto) {
                  final pos = puntosProducto[producto];
                  if (pos == null) return SizedBox();
                  return Positioned(
                    left: size.width * pos.dx - 10,
                    top: size.height * pos.dy - 10,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  );
                }).toList(),

                // Botón para salir
                Positioned(
                  top: 40,
                  left: 16,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                ElevatedButton.icon(
                icon: Icon(Icons.vrpano),
                label: Text("Iniciar guía AR"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ARScreen()),
                  );
                },
                ),

              ],
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
