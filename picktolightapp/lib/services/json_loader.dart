import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/mapa.dart';
import '../models/producto.dart';

Future<Mapa> cargarMapa() async {
  final jsonStr = await rootBundle.loadString('assets/data/mapa.json');
  final data = jsonDecode(jsonStr);
  return Mapa.fromJson(data);
}

Future<List<Producto>> cargarProductos() async {
  final jsonStr = await rootBundle.loadString('assets/data/productos.json');
  final data = jsonDecode(jsonStr);
  return (data['productos'] as List).map((e) => Producto.fromJson(e)).toList();
}
