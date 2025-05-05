import 'package:flutter/material.dart';
import 'screens/ar_screen.dart';
import 'screens/producto_selector_screen.dart'; // Import the new screen

void main() async { // Make main async
  WidgetsFlutterBinding.ensureInitialized(); // Ensure bindings are initialized

  // Placeholder print statements until loading functions are implemented
  print("Simulating data loading...");
  print("Mapa loaded (placeholder)");
  print("Productos loaded (placeholder)");

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pick-to-Light AR Demo',
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Menú principal")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: const Text("Seleccionar Modo de Navegación"),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.qr_code),
                          title: const Text("Modo QR (por puntos de referencia)"),
                          onTap: () {
                            // TODO: ir a escáner QR
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.compass_calibration),
                          title: const Text("Modo sensores (giroscopio + pasos)"),
                          onTap: () {
                            // TODO: activar lógica de IMU
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.map),
                          title: const Text("Modo mapa digital"),
                          onTap: () {
                            // TODO: abrir pantalla de minimapa
                            Navigator.pop(context); // Close the bottom sheet
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.view_in_ar),
                          title: const Text("Modo AR (realidad aumentada)"),
                          onTap: () {
                            Navigator.pop(context); // Close the bottom sheet first
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProductoSelectorScreen()),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
