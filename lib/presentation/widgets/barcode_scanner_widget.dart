import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../core/services/external_barcode_scanner_service.dart';

class BarcodeScannerWidget extends StatefulWidget {
  final Function(String barcode) onBarcodeScanned;

  const BarcodeScannerWidget({
    super.key,
    required this.onBarcodeScanned,
  });

  @override
  State<BarcodeScannerWidget> createState() => _BarcodeScannerWidgetState();
}

class _BarcodeScannerWidgetState extends State<BarcodeScannerWidget> with WidgetsBindingObserver {
  bool _hasPermission = false;
  bool _isScanning = true;
  String? _lastScannedCode;
  MobileScannerController? _scannerController;
  bool _externalScannerEnabled = false;
  bool _externalScannerConnected = false;
  StreamSubscription<String>? _barcodeSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb) {
      _initializeExternalScanner();
    } else {
      _checkPermissionAndInitialize();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!kIsWeb && _scannerController != null) {
      switch (state) {
        case AppLifecycleState.resumed:
          // Restart scanner when app comes to foreground
          _scannerController?.start();
          break;
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
        case AppLifecycleState.hidden:
          // Stop scanner when app goes to background
          _scannerController?.stop();
          break;
      }
    }
  }

  Future<void> _checkPermissionAndInitialize() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      if (mounted) {
        setState(() {
          _hasPermission = true;
        });
        _initializeCamera();
      }
    } else {
      final result = await Permission.camera.request();
      if (result.isGranted && mounted) {
        setState(() {
          _hasPermission = true;
        });
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Small delay to ensure permission is fully processed
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Dispose any previous controller instance
      await _scannerController?.dispose();

      // Initialize mobile scanner controller for mobile (non-web) devices.
      // Using default autoStart behavior for better compatibility
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        formats: [BarcodeFormat.all],
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to initialize camera: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                _initializeCamera();
              },
            ),
          ),
        );
      }
    }
  }

  void _startBarcodeScanning() {
    // Mobile scanner automatically starts scanning when initialized
    // No additional action needed
  }

  void _stopBarcodeScanning() {
    try {
      _scannerController?.stop();
    } catch (e) {
      print('Error stopping barcode scanning: $e');
    }
  }

  /// Initialize external barcode scanner for web
  void _initializeExternalScanner() async {
    // Check if external scanner is available
    final isConnected = await ExternalBarcodeScannerService.instance.isScannerConnected();
    if (mounted) {
      setState(() {
        _externalScannerConnected = isConnected;
        _externalScannerEnabled = isConnected;
      });
    }

    // Listen to barcode stream
    _barcodeSubscription = ExternalBarcodeScannerService.instance.barcodeStream.listen(
      (barcode) {
        if (mounted && _externalScannerEnabled) {
          _handleBarcode(barcode);
        }
      },
    );
  }

  void _handleBarcode(String? code) {
    if (!_isScanning || !mounted || code == null) return;

    if (code.isEmpty || code == _lastScannedCode) return;

    _lastScannedCode = code;
    setState(() {
      _isScanning = false;
    });

    // Call the callback with the scanned barcode
    widget.onBarcodeScanned(code);

    // Resume scanning after a short delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isScanning = true;
          _lastScannedCode = null;
        });
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    // Web version: Show manual input with external scanner support
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Barcode Scanner'),
          actions: [
            if (_externalScannerConnected)
              IconButton(
                icon: Icon(
                  _externalScannerEnabled ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                  color: _externalScannerEnabled ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _externalScannerEnabled = !_externalScannerEnabled;
                  });
                },
                tooltip: _externalScannerEnabled ? 'Disable External Scanner' : 'Enable External Scanner',
              ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _externalScannerEnabled && _externalScannerConnected
                    ? Icons.bluetooth_connected
                    : Icons.qr_code_scanner,
                size: 80,
                color: _externalScannerEnabled && _externalScannerConnected
                    ? Colors.green
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              if (_externalScannerConnected) ...[
                Text(
                  _externalScannerEnabled
                      ? 'External Scanner Active\nScan a barcode with your device'
                      : 'External Scanner Available\nEnable to use external scanner',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: _externalScannerEnabled ? Colors.green : Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _externalScannerEnabled
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _externalScannerEnabled ? Colors.green : Colors.grey.shade300,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _externalScannerEnabled ? Icons.check_circle : Icons.info,
                        color: _externalScannerEnabled ? Colors.green : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _externalScannerEnabled ? 'Scanner Active' : 'Scanner Inactive',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _externalScannerEnabled ? Colors.green : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                const Text(
                  'No external scanner detected\nConnect a USB or Bluetooth scanner',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _checkForScanners,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Check for Scanners'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // Mobile version: Show camera scanner
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          if (_scannerController != null)
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed: () {
                // Toggle flash
                try {
                  _scannerController!.toggleTorch();
                } catch (e) {
                  print('Error toggling flash: $e');
                }
              },
              tooltip: 'Toggle Flash',
            ),
        ],
      ),
      body: !_hasPermission
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.camera_alt_outlined,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Camera permission is required',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please grant camera permission to scan barcodes',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () async {
                      final status = await Permission.camera.request();
                      if (status.isGranted) {
                        _checkPermissionAndInitialize();
                      } else if (status.isPermanentlyDenied) {
                        if (mounted) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Permission Required'),
                              content: const Text(
                                'Camera permission is required to scan barcodes. Please enable it in app settings.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    openAppSettings();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Open Settings'),
                                ),
                              ],
                            ),
                          );
                        }
                      }
                    },
                    child: const Text('Grant Permission'),
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            )
          : _scannerController == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.camera_alt_outlined,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Initializing camera...',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: () {
                          // Try to reinitialize
                          _stopBarcodeScanning();
                          _scannerController?.dispose();
                          _scannerController = null;
                          _initializeCamera();
                        },
                        child: const Text('Retry Camera'),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Go Back'),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Mobile Scanner widget (fills available space)
                    Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _scannerController != null
                            ? MobileScanner(
                                controller: _scannerController!,
                                fit: BoxFit.cover,
                                placeholderBuilder: (context, child) => const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                errorBuilder: (context, error, child) {
                                  debugPrint('MobileScanner error: \\${error.errorCode.name} - \\${error.errorDetails}');

                                  String message;
                                  switch (error.errorCode) {
                                    case MobileScannerErrorCode.permissionDenied:
                                      message = 'Camera permission denied. Please enable it in Settings.';
                                      break;
                                    case MobileScannerErrorCode.unsupported:
                                      message = 'This device does not support camera barcode scanning.';
                                      break;
                                    case MobileScannerErrorCode.controllerAlreadyInitialized:
                                      // Non-fatal: the camera is already running. Show scanner UI.
                                      return child ?? const SizedBox.shrink();
                                    default:
                                      message = 'Unable to start camera for barcode scanning. (Error: ' 
                                          '${error.errorCode.name})';
                                      break;
                                  }

                                  return Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.white, size: 40),
                                        const SizedBox(height: 12),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                          child: Text(
                                            message,
                                            style: const TextStyle(color: Colors.white, fontSize: 14),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                onDetect: (capture) {
                                  final List<Barcode> barcodes = capture.barcodes;
                                  if (barcodes.isNotEmpty && _isScanning && mounted) {
                                    final barcode = barcodes.first;
                                    if (barcode.rawValue != null &&
                                        barcode.rawValue!.isNotEmpty &&
                                        barcode.rawValue != _lastScannedCode) {
                                      _handleBarcode(barcode.rawValue!);
                                    }
                                  }
                                },
                              )
                            : const Center(child: CircularProgressIndicator()),
                      ),
                    ),
                    
                    // Scanning frame overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _ScanningFramePainter(),
                      ),
                    ),
                    
                    // Overlay with scanning instructions
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.qr_code_scanner,
                                  color: _isScanning ? Colors.green : Colors.grey,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _isScanning ? 'Scanning...' : 'Paused',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _isScanning ? Colors.green : Colors.grey,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Point camera at barcode',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  /// Check for connected scanners
  Future<void> _checkForScanners() async {
    final isConnected = await ExternalBarcodeScannerService.instance.isScannerConnected();
    if (mounted) {
      setState(() {
        _externalScannerConnected = isConnected;
        _externalScannerEnabled = isConnected;
      });
      
      if (isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('External scanner detected!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No external scanner found. Please connect a USB or Bluetooth scanner.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopBarcodeScanning();
    _scannerController?.dispose();
    _barcodeSubscription?.cancel();
    super.dispose();
  }
}

// Custom painter for scanning frame overlay
class _ScanningFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final frameSize = size.width * 0.7;
    final frameRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: frameSize,
      height: frameSize,
    );

    // Draw corner brackets
    final cornerLength = 30.0;
    final cornerPaint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    // Top-left corner
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top),
      Offset(frameRect.left + cornerLength, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.top),
      Offset(frameRect.left, frameRect.top + cornerLength),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(frameRect.right, frameRect.top),
      Offset(frameRect.right - cornerLength, frameRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.top),
      Offset(frameRect.right, frameRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom),
      Offset(frameRect.left + cornerLength, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.left, frameRect.bottom),
      Offset(frameRect.left, frameRect.bottom - cornerLength),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(frameRect.right, frameRect.bottom),
      Offset(frameRect.right - cornerLength, frameRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(frameRect.right, frameRect.bottom),
      Offset(frameRect.right, frameRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}