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

  void _iniciarRutaDesdeQR(BuildContext context, String qrCode) async {
    final jsonStr = await rootBundle.loadString('assets/data/mapa.json');
    final data = jsonDecode(jsonStr);
    final zonas = List<Map<String, dynamic>>.from(data["mapa"]["zonas"]);

    // Busca la zona o góndola correspondiente al QR escaneado
    final zona = zonas.firstWhere(
      (z) => z["id"].toString().toLowerCase() == qrCode.toLowerCase(),
      orElse: () => {"id": "entrada", "x": 6.5, "y": 7.5}, // Por defecto, usa "entrada"
    );

    // Crea un punto de inicio basado en el QR escaneado
    final puntoInicio = Producto(
      id: zona["id"],
      nombre: zona["id"],
      x: zona["x"],
      y: zona["y"],
    );

    // Navega al mapa 2D con el punto de inicio
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Mapa2DWidget(
          productos: [...seleccionados, puntoInicio], // Incluye el punto de inicio como ancla visual
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
                    // Habilita el envío a Firebase
                    await FirebaseService.actualizarGondolasFirestore(seleccionados);

                    seleccionarModoNavegacion(context);
                  },
          ),
          const SizedBox(height: 16),
          ExpansionTile(
            title: const Text("Ver productos seleccionados"),
            children: [
              ...seleccionados.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final p = entry.value;
                return ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor: Colors.orange,
                    child: Text(
                      '$index',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  title: Text(p.nombre),
                  subtitle: Text("Góndola: ${p.gondola ?? "?"}"),
                );
              })
            ],
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
