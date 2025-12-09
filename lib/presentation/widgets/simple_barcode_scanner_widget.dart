import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SimpleBarcodeScannerWidget extends StatefulWidget {
  final Function(String barcode) onBarcodeScanned;

  const SimpleBarcodeScannerWidget({
    super.key,
    required this.onBarcodeScanned,
  });

  @override
  State<SimpleBarcodeScannerWidget> createState() => _SimpleBarcodeScannerWidgetState();
}

class _SimpleBarcodeScannerWidgetState extends State<SimpleBarcodeScannerWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  bool _isScanning = false;

  void _handleSubmit() {
    final barcode = _barcodeController.text.trim();
    if (barcode.isNotEmpty) {
      widget.onBarcodeScanned(barcode);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Barcode'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.qr_code_scanner,
              size: 100,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 32),
            const Text(
              'Enter Barcode Manually',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Type or scan the barcode below',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              constraints: const BoxConstraints(maxWidth: 400),
              child: TextField(
                controller: _barcodeController,
                style: const TextStyle(fontSize: 18),
                decoration: InputDecoration(
                  labelText: 'Barcode',
                  hintText: 'Enter barcode number',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _handleSubmit(),
                autofocus: true,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search Product',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            if (_isScanning)
              const Padding(
                padding: EdgeInsets.only(top: 16),
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // For future implementation - show message about camera scanning
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Camera scanning is temporarily disabled. Please use manual entry.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
        },
        backgroundColor: Colors.grey.shade300,
        child: const Icon(Icons.info_outline),
      ),
    );
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    super.dispose();
  }
}