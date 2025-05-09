import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto.dart';

class FirebaseService {
  static final _docRef = FirebaseFirestore.instance
      .collection("Guiado")
      .doc("EstadoGondolas");

  static Future<void> actualizarGondolasFirestore(List<Producto> productos) async {
    // Obtener el documento actual
    final snapshot = await _docRef.get();
    final data = snapshot.data() ?? {};

    // 1. Apagar todas
    final actualizacion = <String, dynamic>{
      for (final key in data.keys) key: false,
    };

    // 2. Encender las necesarias
    for (final p in productos) {
      if (p.gondola != null) {
        actualizacion[p.gondola!] = true;
      }
    }

    // 3. Enviar actualización
    await _docRef.set(actualizacion);
  }
}
