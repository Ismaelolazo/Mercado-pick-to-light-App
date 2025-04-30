import 'package:flutter/material.dart';
import 'package:ar_flutter_plugin/ar_flutter_plugin.dart';
// Oculta el conflicto de nombres entre Colors de Flutter y vector_math
import 'package:vector_math/vector_math_64.dart' as vector;

class ARScreen extends StatelessWidget {
  const ARScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Demo')),
      body: ARView(
        onARViewCreated: (sessionManager, objectManager, anchorManager, locationManager) async {
          await sessionManager.onInitialize(
            showFeaturePoints: false,
            showPlanes: true,
            customPlaneTexturePath: "assets/blue_grid.png",
            showWorldOrigin: true,
          );
          await objectManager.onInitialize();

          await objectManager.addNode(
            ARNode(
              type: NodeType.sphere,
              position: vector.Vector3(0.0, 0.0, -1.5),
              scale: vector.Vector3.all(0.1),
              materials: [
                ARMaterial(color: Colors.orange),
              ],
            ),
          );
        },
      ),
    );
  }
}
