import 'package:flutter/material.dart';
import 'camera_screen.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  const HomeScreen({Key? key, required this.cameras}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> productos = ['Leche', 'Pan', 'Manzana', 'Yogurt', 'Arroz'];
  final Map<String, bool> seleccionados = {};

  @override
  void initState() {
    super.initState();
    for (var producto in productos) {
      seleccionados[producto] = false;
    }
  }

  void _iniciarRuta() {
    final seleccion = seleccionados.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    if (seleccion.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selecciona al menos un producto')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            CameraScreen(cameras: widget.cameras, productos: seleccion),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shopping_cart_outlined),
            SizedBox(width: 8),
            Text('Tus productos'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: productos.map((producto) {
                return CheckboxListTile(
                title: Text(producto, style: TextStyle(fontSize: 18)),
                activeColor: Theme.of(context).colorScheme.secondary,
                value: seleccionados[producto],
                onChanged: (bool? value) {
                  setState(() {
                    seleccionados[producto] = value ?? false;
                  });
                },
              );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.route),
              label: Text('Iniciar ruta'),
              onPressed: _iniciarRuta,
              style: ElevatedButton.styleFrom(minimumSize: Size.fromHeight(50)),
            ),
          ),
        ],
      ),
    );
  }
}
