import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerSimple extends StatefulWidget {
  const BarcodeScannerSimple({super.key});

  @override
  State<BarcodeScannerSimple> createState() => _BarcodeScannerSimpleState();
}

class _BarcodeScannerSimpleState extends State<BarcodeScannerSimple> {
  final MobileScannerController controller = MobileScannerController();

  void _handleBarcode(BarcodeCapture barcodes) async {
    if (mounted) {
      await controller.stop();
      await controller.dispose();
      Navigator.pop(context, barcodes.barcodes.firstOrNull?.displayValue);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scanne das Wartungsobjekt')),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
          ),
        ],
      ),
    );
  }
}
