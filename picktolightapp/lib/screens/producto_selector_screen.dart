import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'ar_screen.dart';

class ProductoSelectorScreen extends StatefulWidget {
  const ProductoSelectorScreen({super.key});

  @override
  State<ProductoSelectorScreen> createState() => _ProductoSelectorScreenState();
}

class _ProductoSelectorScreenState extends State<ProductoSelectorScreen> {
  List<Map<String, dynamic>> productos = [];
  Map<String, dynamic>? productoSeleccionado;

  @override
  void initState() {
    super.initState();
    cargarProductos();
  }

  Future<void> cargarProductos() async {
    final jsonStr = await rootBundle.loadString('assets/data/productos.json');
    final data = jsonDecode(jsonStr);
    setState(() {
      productos = List<Map<String, dynamic>>.from(data["productos"]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Selecciona un producto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<Map<String, dynamic>>(
              hint: const Text("Seleccionar producto"),
              value: productoSeleccionado,
              isExpanded: true,
              items: productos.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(p["nombre"]),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  productoSeleccionado = value;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: productoSeleccionado == null
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ArSupermercado(producto: productoSeleccionado!),
                        ),
                      );
                    },
              child: const Text("Iniciar recorrido en AR"),
            ),
          ],
        ),
      ),
    );
  }
}
