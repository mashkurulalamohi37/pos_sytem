import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional import: use web implementation on web, stub on other platforms
import 'external_barcode_scanner_service_stub.dart'
    if (dart.library.html) 'external_barcode_scanner_service_web.dart';

/// Configuration for barcode scanner settings
class BarcodeScannerConfig {
  final bool enabled;
  final int inputTimeout; // milliseconds
  final int minBarcodeLength;
  final bool autoSubmit;

  const BarcodeScannerConfig({
    this.enabled = false,
    this.inputTimeout = 100,
    this.minBarcodeLength = 3,
    this.autoSubmit = true,
  });

  BarcodeScannerConfig copyWith({
    bool? enabled,
    int? inputTimeout,
    int? minBarcodeLength,
    bool? autoSubmit,
  }) {
    return BarcodeScannerConfig(
      enabled: enabled ?? this.enabled,
      inputTimeout: inputTimeout ?? this.inputTimeout,
      minBarcodeLength: minBarcodeLength ?? this.minBarcodeLength,
      autoSubmit: autoSubmit ?? this.autoSubmit,
    );
  }
}

/// Service for handling external barcode scanners on web platform
class ExternalBarcodeScannerService {
  static ExternalBarcodeScannerService? _instance;
  static ExternalBarcodeScannerService get instance {
    _instance ??= ExternalBarcodeScannerService._();
    return _instance!;
  }

  ExternalBarcodeScannerService._();

  StreamController<String>? _barcodeStreamController;
  Stream<String>? _barcodeStream;
  Timer? _inputTimer;
  String _currentInput = '';
  BarcodeScannerConfig _config = const BarcodeScannerConfig();
  bool _isListening = false;

  /// Current scanner configuration
  BarcodeScannerConfig get config => _config;

  /// Update scanner configuration
  void updateConfig(BarcodeScannerConfig config) {
    _config = config;
    if (!_config.enabled && _isListening) {
      _stopListening();
    }
  }

  /// Stream of scanned barcodes
  Stream<String> get barcodeStream {
    if (!kIsWeb || !_config.enabled) return Stream.empty();
    
    _barcodeStreamController ??= StreamController<String>.broadcast(
      onListen: _startListening,
      onCancel: _stopListening,
    );
    _barcodeStream ??= _barcodeStreamController!.stream;
    return _barcodeStream!;
  }

  /// Start listening for barcode scanner input
  void _startListening() {
    if (!kIsWeb || _isListening || !_config.enabled) return;
    
    _isListening = true;
    document.addEventListener('keydown', _handleKeyDown);
  }

  /// Stop listening for barcode scanner input
  void _stopListening() {
    if (!kIsWeb || !_isListening) return;
    
    _isListening = false;
    document.removeEventListener('keydown', _handleKeyDown);
    _inputTimer?.cancel();
    _inputTimer = null;
    _currentInput = '';
  }

  /// Handle keyboard events for barcode scanner input
  void _handleKeyDown(Event event) {
    if (!_isListening || !kIsWeb) return;
    
    // On web, check if it's a KeyboardEvent
    if (kIsWeb && event is! KeyboardEvent) return;

    // Cast to keyboard event only on web
    final keyboardEvent = kIsWeb ? event as KeyboardEvent : null;
    if (keyboardEvent == null) return;
    
    final key = keyboardEvent.key ?? '';
    
    // Check if it's a barcode scanner input
    // Most barcode scanners send data rapidly and end with Enter key
    if (key == 'Enter') {
      if (_currentInput.isNotEmpty) {
        _processBarcode(_currentInput);
        _currentInput = '';
        _inputTimer?.cancel();
        _inputTimer = null;
      }
    } else if (key.length == 1 ||
               key == 'Shift' ||
               key == 'Control' ||
               key == 'Alt') {
      // Regular character input or modifier keys
      if (key.length == 1) {
        _currentInput += key;
        _resetInputTimer();
      }
    } else if (key == 'Backspace') {
      // Handle backspace
      if (_currentInput.isNotEmpty) {
        _currentInput = _currentInput.substring(0, _currentInput.length - 1);
        _resetInputTimer();
      }
    }
  }

  /// Reset the input timer
  void _resetInputTimer() {
    _inputTimer?.cancel();
    _inputTimer = Timer(Duration(milliseconds: _config.inputTimeout), () {
      if (_currentInput.isNotEmpty) {
        _processBarcode(_currentInput);
        _currentInput = '';
      }
    });
  }

  /// Process the scanned barcode
  void _processBarcode(String barcode) {
    // Validate barcode using configured minimum length
    final trimmedBarcode = barcode.trim();
    if (trimmedBarcode.length >= _config.minBarcodeLength) {
      _barcodeStreamController?.add(trimmedBarcode);
    }
  }

  /// Check if WebUSB API is available
  bool get isWebUSBSupported {
    if (!kIsWeb) return false;
    try {
      // Use js_util package for proper JavaScript interop in a real implementation
      // For now, use a simple check
      return document.querySelector('script[src*="usb"]') != null ||
             document.querySelector('script[src*="webusb"]') != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if Web Bluetooth API is available
  bool get isWebBluetoothSupported {
    if (!kIsWeb) return false;
    try {
      // Use js_util package for proper JavaScript interop in a real implementation
      // For now, use a simple check
      return document.querySelector('script[src*="bluetooth"]') != null ||
             document.querySelector('script[src*="webbluetooth"]') != null;
    } catch (e) {
      return false;
    }
  }

  /// Request USB barcode scanner device (if WebUSB is supported)
  Future<Map<String, dynamic>?> requestUsbDevice() async {
    if (!isWebUSBSupported) return null;

    try {
      // Note: WebUSB API requires additional setup and permissions
      // This is a simplified implementation
      // In a real implementation, you would use the js_util package
      // to properly interact with the WebUSB API
      return {
        'status': 'WebUSB detected but not fully implemented',
        'message': 'Would request USB barcode scanner device here'
      };
    } catch (e) {
      print('Error requesting USB device: $e');
      return null;
    }
  }

  /// Request Bluetooth barcode scanner device (if Web Bluetooth is supported)
  Future<Map<String, dynamic>?> requestBluetoothDevice() async {
    if (!isWebBluetoothSupported) return null;

    try {
      // Note: Web Bluetooth API requires additional setup and permissions
      // This is a simplified implementation
      // In a real implementation, you would use the js_util package
      // to properly interact with the Web Bluetooth API
      return {
        'status': 'Web Bluetooth detected but not fully implemented',
        'message': 'Would request Bluetooth barcode scanner device here'
      };
    } catch (e) {
      print('Error requesting Bluetooth device: $e');
      return null;
    }
  }

  /// Check if any barcode scanner is connected (simplified check)
  Future<bool> isScannerConnected() async {
    if (!kIsWeb) return false;
    
    // This is a simplified check - in a real implementation,
    // you would check for specific USB/Bluetooth devices
    // For now, we assume keyboard input scanners are always "available"
    // since they work as HID keyboard devices
    return true; // Most barcode scanners work as keyboard devices
  }

  /// Dispose the service
  void dispose() {
    _stopListening();
    _barcodeStreamController?.close();
    _barcodeStreamController = null;
    _barcodeStream = null;
  }
}