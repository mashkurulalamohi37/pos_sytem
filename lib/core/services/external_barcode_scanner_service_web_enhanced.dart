import 'dart:async';
import 'dart:js_interop';
import 'package:web/web.dart' as web;

/// Enhanced external barcode scanner service for web with WiFi, Bluetooth, and USB support
class ExternalBarcodeScannerServiceWeb {
  // Singleton instance
  static ExternalBarcodeScannerServiceWeb? _instance;
  static ExternalBarcodeScannerServiceWeb get instance {
    _instance ??= ExternalBarcodeScannerServiceWeb._();
    return _instance!;
  }

  ExternalBarcodeScannerServiceWeb._();

  // Connection types
  enum ConnectionType { keyboard, usb, bluetooth, wifi, none }
  
  ConnectionType _currentConnection = ConnectionType.none;
  ConnectionType get currentConnection => _currentConnection;

  // Bluetooth device
  web.BluetoothDevice? _bluetoothDevice;
  web.BluetoothRemoteGATTCharacteristic? _bluetoothCharacteristic;
  
  // USB device  
  web.USBDevice? _usbDevice;
  
  // WiFi/Network scanner
  String? _wifiScannerUrl;
  Timer? _wifiPollTimer;

  /// Check if Web Bluetooth is supported
  bool get isBluetoothSupported {
    try {
      return web.window.navigator.bluetooth != null;
    } catch (e) {
      return false;
    }
  }

  /// Check if WebUSB is supported
  bool get isUsbSupported {
    try {
      return web.window.navigator.usb != null;
    } catch (e) {
      return false;
    }
  }

  /// Request and connect to a Bluetooth barcode scanner
  Future<bool> connectBluetooth() async {
    if (!isBluetoothSupported) {
      throw Exception('Web Bluetooth is not supported in this browser');
    }

    try {
      // Request Bluetooth device
      final options = web.RequestDeviceOptions(
        filters: [
          web.BluetoothLEScanFilter(
            services: ['battery_service'.toJS].toJS, // Generic service
          ),
        ].toJS,
        optionalServices: [
          'generic_access'.toJS,
          'device_information'.toJS,
        ].toJS,
      );

      _bluetoothDevice = await web.window.navigator.bluetooth!.requestDevice(options).toDart;
      
      if (_bluetoothDevice == null) {
        return false;
      }

      // Connect to GATT server
      final server = await _bluetoothDevice!.gatt!.connect().toDart;
      
      // Get the service (you'll need to know your scanner's service UUID)
      // This is a generic example - replace with your scanner's actual service UUID
      final service = await server.getPrimaryService('battery_service'.toJS).toDart;
      
      // Get characteristic for barcode data
      // Replace with your scanner's characteristic UUID
      _bluetoothCharacteristic = await service.getCharacteristic('battery_level'.toJS).toDart;
      
      // Start notifications
      await _bluetoothCharacteristic!.startNotifications().toDart;
      
      // Listen for barcode data
      _bluetoothCharacteristic!.addEventListener('characteristicvaluechanged', _handleBluetoothData.toJS);
      
      _currentConnection = ConnectionType.bluetooth;
      return true;
    } catch (e) {
      print('Bluetooth connection error: $e');
      return false;
    }
  }

  /// Handle Bluetooth data
  void _handleBluetoothData(web.Event event) {
    try {
      if (_bluetoothCharacteristic == null) return;
      
      final value = _bluetoothCharacteristic!.value;
      if (value == null) return;
      
      // Convert DataView to String
      final bytes = <int>[];
      for (var i = 0; i < value.byteLength; i++) {
        bytes.add(value.getUint8(i));
      }
      
      final barcode = String.fromCharCodes(bytes);
      if (barcode.isNotEmpty) {
        _barcodeStreamController?.add(barcode.trim());
      }
    } catch (e) {
      print('Error handling Bluetooth data: $e');
    }
  }

  /// Disconnect Bluetooth device
  Future<void> disconnectBluetooth() async {
    try {
      if (_bluetoothCharacteristic != null) {
        await _bluetoothCharacteristic!.stopNotifications().toDart;
        _bluetoothCharacteristic!.removeEventListener('characteristicvaluechanged', _handleBluetoothData.toJS);
        _bluetoothCharacteristic = null;
      }
      
      if (_bluetoothDevice != null && _bluetoothDevice!.gatt!.connected) {
        _bluetoothDevice!.gatt!.disconnect();
        _bluetoothDevice = null;
      }
      
      if (_currentConnection == ConnectionType.bluetooth) {
        _currentConnection = ConnectionType.none;
      }
    } catch (e) {
      print('Error disconnecting Bluetooth: $e');
    }
  }

  /// Request and connect to a USB barcode scanner
  Future<bool> connectUsb() async {
    if (!isUsbSupported) {
      throw Exception('WebUSB is not supported in this browser');
    }

    try {
      // Request USB device
      final options = web.USBDeviceRequestOptions(
        filters: [
          // Add filters for common barcode scanner vendors
          web.USBDeviceFilter(
            vendorId: 0x05e0, // Symbol/Motorola
          ),
          web.USBDeviceFilter(
            vendorId: 0x0c2e, // Honeywell
          ),
          web.USBDeviceFilter(
            vendorId: 0x1504, // Zebra
          ),
          web.USBDeviceFilter(
            vendorId: 0x0536, // Datalogic
          ),
        ].toJS,
      );

      _usbDevice = await web.window.navigator.usb!.requestDevice(options).toDart;
      
      if (_usbDevice == null) {
        return false;
      }

      // Open and configure the device
      await _usbDevice!.open().toDart;
      await _usbDevice!.selectConfiguration(1).toDart;
      await _usbDevice!.claimInterface(0).toDart;
      
      // Start reading data
      _startUsbReading();
      
      _currentConnection = ConnectionType.usb;
      return true;
    } catch (e) {
      print('USB connection error: $e');
      return false;
    }
  }

  /// Start reading from USB device
  void _startUsbReading() async {
    if (_usbDevice == null) return;
    
    try {
      while (_usbDevice != null && _currentConnection == ConnectionType.usb) {
        // Read from endpoint (typically endpoint 1 for input)
        final result = await _usbDevice!.transferIn(1, 64).toDart;
        
        if (result.data != null && result.data!.byteLength > 0) {
          // Convert data to string
          final bytes = <int>[];
          for (var i = 0; i < result.data!.byteLength; i++) {
            bytes.add(result.data!.getUint8(i));
          }
          
          final barcode = String.fromCharCodes(bytes);
          if (barcode.isNotEmpty) {
            _barcodeStreamController?.add(barcode.trim());
          }
        }
        
        // Small delay to prevent CPU overuse
        await Future.delayed(const Duration(milliseconds: 10));
      }
    } catch (e) {
      print('Error reading USB data: $e');
    }
  }

  /// Disconnect USB device
  Future<void> disconnectUsb() async {
    try {
      if (_usbDevice != null) {
        await _usbDevice!.releaseInterface(0).toDart;
        await _usbDevice!.close().toDart;
        _usbDevice = null;
      }
      
      if (_currentConnection == ConnectionType.usb) {
        _currentConnection = ConnectionType.none;
      }
    } catch (e) {
      print('Error disconnecting USB: $e');
    }
  }

  /// Connect to WiFi/Network barcode scanner
  /// This connects to a scanner that exposes an HTTP endpoint
  Future<bool> connectWifi(String scannerUrl) async {
    try {
      _wifiScannerUrl = scannerUrl;
      
      // Test connection
      final response = await web.window.fetch(scannerUrl.toJS).toDart;
      if (response.status != 200) {
        return false;
      }
      
      // Start polling for scans
      _startWifiPolling();
      
      _currentConnection = ConnectionType.wifi;
      return true;
    } catch (e) {
      print('WiFi connection error: $e');
      return false;
    }
  }

  /// Start polling WiFi scanner for new scans
  void _startWifiPolling() {
    _wifiPollTimer?.cancel();
    _wifiPollTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) async {
      if (_wifiScannerUrl == null || _currentConnection != ConnectionType.wifi) {
        timer.cancel();
        return;
      }
      
      try {
        final response = await web.window.fetch('$_wifiScannerUrl/scan'.toJS).toDart;
        if (response.status == 200) {
          final text = await response.text().toDart;
          if (text.isNotEmpty) {
            _barcodeStreamController?.add(text.trim());
          }
        }
      } catch (e) {
        // Silently fail - scanner might not have data
      }
    });
  }

  /// Disconnect WiFi scanner
  void disconnectWifi() {
    _wifiPollTimer?.cancel();
    _wifiPollTimer = null;
    _wifiScannerUrl = null;
    
    if (_currentConnection == ConnectionType.wifi) {
      _currentConnection = ConnectionType.none;
    }
  }

  /// Disconnect all devices
  Future<void> disconnectAll() async {
    await disconnectBluetooth();
    await disconnectUsb();
    disconnectWifi();
    _currentConnection = ConnectionType.none;
  }

  /// Get connection status
  String getConnectionStatus() {
    switch (_currentConnection) {
      case ConnectionType.keyboard:
        return 'Connected via Keyboard (HID)';
      case ConnectionType.usb:
        return 'Connected via USB';
      case ConnectionType.bluetooth:
        return 'Connected via Bluetooth';
      case ConnectionType.wifi:
        return 'Connected via WiFi/Network';
      case ConnectionType.none:
        return 'Not Connected';
    }
  }

  // Stream controller for barcode data
  StreamController<String>? _barcodeStreamController;
  
  Stream<String> get barcodeStream {
    _barcodeStreamController ??= StreamController<String>.broadcast();
    return _barcodeStreamController!.stream;
  }

  /// Dispose the service
  void dispose() {
    disconnectAll();
    _barcodeStreamController?.close();
    _barcodeStreamController = null;
  }
}
