import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picktolightapp/models/producto.dart';
import 'package:picktolightapp/screens/ar_screen.dart';
import 'package:picktolightapp/widgets/mapa_2d.dart';


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
      builder: (_) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.view_in_ar),
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
              leading: const Icon(Icons.map),
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
              leading: const Icon(Icons.route),
              title: const Text("Ruta paso a paso"),
              onTap: () {
                // implementar pantalla futura
              },
            ),
            ListTile(
              leading: const Icon(Icons.qr_code),
              title: const Text("Navegación con QR"),
              onTap: () {
                // implementar pantalla futura
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona productos")),
      body: ListView(
        children: [
          ...productos.map((p) {
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
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: seleccionados.isEmpty
                  ? null
                  : () => seleccionarModoNavegacion(context),
              child: const Text("Iniciar ruta"),
            ),
          ),
        ],
      ),
    );
  }
}
