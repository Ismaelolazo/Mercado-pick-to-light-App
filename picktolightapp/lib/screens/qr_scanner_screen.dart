import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatelessWidget {
  final void Function(String) onScanned;

  const QrScannerScreen({super.key, required this.onScanned});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Escanear QR")),
      body: MobileScanner(
      onDetect: (capture) {
        final barcode = capture.barcodes.first;
        if (barcode.rawValue != null) {
          Navigator.pop(context);
          onScanned(barcode.rawValue!);
    }
  },
)
,
    );
  }
}
