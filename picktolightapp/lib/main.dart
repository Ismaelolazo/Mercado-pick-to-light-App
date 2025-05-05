import 'package:flutter/material.dart';
import 'package:picktolightapp/screens/producto_selector_screen.dart';


void main() {
  runApp(const PickToLightApp());
}

class PickToLightApp extends StatelessWidget {
  const PickToLightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pick-to-Light AR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        useMaterial3: true,
      ),
      home: const MenuPrincipal(),
    );
  }
}

class MenuPrincipal extends StatelessWidget {
  const MenuPrincipal({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sistema Pick-to-Light")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductoSelectorScreen()),
            );
          },
          child: const Text("Seleccionar productos"),
        ),
      ),
    );
  }
}
