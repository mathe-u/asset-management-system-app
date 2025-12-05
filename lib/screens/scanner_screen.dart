import 'package:assets/models/asset.dart';
import 'package:assets/screens/asset_detail_screen.dart';
import 'package:assets/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _ScannerScreenState();
  }
}

class _ScannerScreenState extends State<ScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? _scannedValue;
  bool _isTorchOn = false;
  bool _isFrontCamera = false;
  bool _isLoading = false;

  void _onDetect(BarcodeCapture capture) async {
    final List<Barcode> barcodes = capture.barcodes;

    if (_isLoading) return;

    for (final Barcode barcode in barcodes) {
      final code = barcode.rawValue;

      if (code != null && code != _scannedValue) {
        setState(() {
          _scannedValue = code;
          _isLoading = true;
        });

        await cameraController.stop();

        try {
          final Asset asset = await ApiService.getAssetByCode(code);

          if (mounted) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AssetDetailScreen(asset: asset),
              ),
            );
            // cameraController.stop();
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Ativo não encontrado: $e')));
          }
        } finally {
          if (mounted) {
            await Future.delayed(const Duration(microseconds: 200));
            await cameraController.start();
            setState(() {
              _isLoading = false;
            });
          }
        }
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner'),
        actions: [
          IconButton(
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {
                _isTorchOn = !_isTorchOn;
              });
            },
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? Colors.yellow : Colors.grey,
            ),
          ),
          IconButton(
            onPressed: () async {
              await cameraController.switchCamera();
              setState(() {
                _isFrontCamera = !_isFrontCamera;
              });
            },
            icon: Icon(_isFrontCamera ? Icons.camera_front : Icons.camera_rear),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: Stack(
              children: [
                MobileScanner(
                  controller: cameraController,
                  onDetect: _onDetect,
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: const Color(0xFFF8F9FA),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _scannedValue != null
                        ? 'Último: $_scannedValue'
                        : 'Aponte para o codigo de barras...',
                    style: const TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  // ElevatedButton(
                  //   onPressed: () async {
                  //     await cameraController.start();
                  //     setState(() {
                  //       _scannedValue = null;
                  //       _isLoading = false;
                  //     });
                  //   },
                  //   style: ButtonStyle(
                  //     backgroundColor: WidgetStatePropertyAll(
                  //       const Color(0xFFF3F4F6),
                  //     ),
                  //   ),

                  //   child: const Text(
                  //     'Reiniciar Scanner',
                  //     style: TextStyle(color: Colors.black),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
