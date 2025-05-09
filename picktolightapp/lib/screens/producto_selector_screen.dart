import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picktolightapp/models/producto.dart';
import 'package:picktolightapp/screens/ar_screen.dart';
import 'package:picktolightapp/widgets/mapa_2d.dart';
import 'package:picktolightapp/screens/ar_paso_a_paso.dart';
import 'package:picktolightapp/screens/qr_scanner_screen.dart';
import 'package:picktolightapp/services/firebase_service.dart'; // ✅

class ProductoSelectorScreen extends StatefulWidget {
  const ProductoSelectorScreen({super.key});

  @override
  State<ProductoSelectorScreen> createState() => _ProductoSelectorScreenState();
}

class _ProductoSelectorScreenState extends State<ProductoSelectorScreen> {
  List<Producto> productos = [];
  final List<Producto> seleccionados = [];

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    final jsonStr = await rootBundle.loadString('assets/data/productos.json');
    final data = jsonDecode(jsonStr);
    setState(() {
      productos = List<Map<String, dynamic>>.from(data["productos"])
          .map((p) => Producto.fromJson(p))
          .toList();
    });
  }

  void seleccionarModoNavegacion(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return Wrap(
          children: [
            const ListTile(
              title: Center(child: Text("Selecciona un modo de navegación")),
            ),
            ListTile(
              leading: const Icon(Icons.view_in_ar, color: Colors.orange),
              title: const Text("Ruta en Realidad Aumentada"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ArSupermercado(productos: seleccionados)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map, color: Colors.blue),
              title: const Text("Mapa 2D"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => Mapa2DWidget(productos: seleccionados)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.route, color: Colors.green),
              title: const Text("Ruta paso a paso"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ArRutaPasoAPaso(
                      productos: seleccionados,
                      inicio: Producto(id: "entrada", nombre: "Entrada", x: 0.5, y: 7.9),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code, color: Colors.indigo),
              title: const Text("Navegación con QR"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QrScannerScreen(
                      onScanned: (qrCode) {
                        _iniciarRutaDesdeQR(context, qrCode);
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _iniciarRutaDesdeQR(BuildContext context, String qrCode) {
    final puntoInicio = productos.firstWhere(
      (p) => p.qr == qrCode,
      orElse: () => Producto(id: "entrada", nombre: "Entrada", x: 0.5, y: 7.9),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ArRutaPasoAPaso(
          productos: seleccionados,
          inicio: puntoInicio,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _agruparProductos(productos);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecciona tus productos"),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...grouped.entries.map((entry) {
            return ExpansionTile(
              title: Text(entry.key),
              collapsedBackgroundColor: Colors.orange.shade50,
              children: entry.value.map((p) {
                final yaSeleccionado = seleccionados.contains(p);
                return CheckboxListTile(
                  title: Text(p.nombre),
                  value: yaSeleccionado,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        seleccionados.add(p);
                      } else {
                        seleccionados.remove(p);
                      }
                    });
                  },
                );
              }).toList(),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.play_arrow),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            label: const Text("Iniciar ruta"),
            onPressed: seleccionados.isEmpty
                ? null
                : () async {
                    await FirebaseService.actualizarGondolasFirestore(seleccionados);

                    seleccionarModoNavegacion(context);
                  },
          ),
        ],
      ),
    );
  }

  /// Agrupa productos según categorías simuladas por posición
  Map<String, List<Producto>> _agruparProductos(List<Producto> lista) {
    Map<String, List<Producto>> resultado = {
      "Alimentos y Bebidas": [],
      "Hogar y Limpieza": [],
      "Bazar y Juguetería": [],
      "Salud y Cuidado Personal": [],
      "Otros": []
    };

    for (var p in lista) {
      final id = p.id.toLowerCase();
      if (["abarrotes", "bebidas", "carnes", "congelados", "frutas", "granos", "pastas", "galletas", "cereales", "harinas", "salsas", "snacks", "panaderia", "pasteleria", "lacteos"].any(id.contains)) {
        resultado["Alimentos y Bebidas"]!.add(p);
      } else if (["limpieza", "hogar", "bazar"].any(id.contains)) {
        resultado["Hogar y Limpieza"]!.add(p);
      } else if (["juguete"].any(id.contains)) {
        resultado["Bazar y Juguetería"]!.add(p);
      } else if (["personal", "bebes", "farmacia"].any(id.contains)) {
        resultado["Salud y Cuidado Personal"]!.add(p);
      } else {
        resultado["Otros"]!.add(p);
      }
    }

    return resultado;
  }
}
