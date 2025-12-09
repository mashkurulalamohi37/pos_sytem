# Barcode Scanner - WiFi/Bluetooth/USB Support

## Overview
Enhanced barcode scanner support for web with multiple connection types:
- **USB** - Direct USB connection via WebUSB API
- **Bluetooth** - Wireless connection via Web Bluetooth API  
- **WiFi/Network** - HTTP-based network scanners
- **Keyboard (HID)** - Traditional keyboard emulation (existing)

## Features Added

### 1. Connection Type Selection
Users can now choose their preferred connection method:
- Auto-detect and connect to USB scanners
- Pair with Bluetooth barcode scanners
- Configure WiFi/Network scanner endpoints
- Use traditional keyboard-mode scanners

### 2. Web Bluetooth Support
- Scan and pair with Bluetooth LE barcode scanners
- Automatic reconnection
- Real-time data streaming
- Battery level monitoring

### 3. WebUSB Support
- Direct USB device access
- Support for major scanner brands:
  - Symbol/Motorola (Vendor ID: 0x05e0)
  - Honeywell (Vendor ID: 0x0c2e)
  - Zebra (Vendor ID: 0x1504)
  - Datalogic (Vendor ID: 0x0536)
- Low-latency data transfer

### 4. WiFi/Network Scanner Support
- HTTP endpoint configuration
- Polling-based data retrieval
- Support for REST API scanners
- Custom URL configuration

## Browser Compatibility

### Web Bluetooth
✅ Chrome/Edge 56+
✅ Opera 43+
❌ Firefox (requires flag)
❌ Safari (not supported)

### WebUSB
✅ Chrome/Edge 61+
✅ Opera 48+
❌ Firefox (not supported)
❌ Safari (not supported)

### Keyboard (HID)
✅ All browsers

## Setup Instructions

### For USB Scanners

1. **Connect Scanner**
   - Plug USB scanner into computer
   - Ensure scanner is powered on

2. **Grant Permissions**
   - Click "Connect USB Scanner"
   - Select your scanner from the list
   - Grant permission when prompted

3. **Configure**
   - Scanner should auto-detect
   - Adjust settings as needed

### For Bluetooth Scanners

1. **Pair Scanner**
   - Turn on Bluetooth scanner
   - Put scanner in pairing mode
   - Click "Connect Bluetooth Scanner"

2. **Grant Permissions**
   - Select scanner from list
   - Grant Bluetooth permission

3. **Configure**
   - Ensure scanner sends data on scan
   - Test connection

### For WiFi/Network Scanners

1. **Connect Scanner to Network**
   - Ensure scanner is on same network
   - Note scanner's IP address

2. **Configure Endpoint**
   - Enter scanner URL (e.g., `http://192.168.1.100`)
   - Test connection
   - Configure polling interval

3. **API Format**
   - Scanner should expose `/scan` endpoint
   - Should return barcode as plain text
   - Example: `GET http://scanner-ip/scan` → `"1234567890"`

## Usage

### In Settings Screen

```dart
// Connect to Bluetooth scanner
await ExternalBarcodeScannerService.instance.connectBluetooth();

// Connect to USB scanner
await ExternalBarcodeScannerService.instance.connectUsb();

// Connect to WiFi scanner
await ExternalBarcodeScannerService.instance.connectWifi('http://192.168.1.100');

// Listen for scans
ExternalBarcodeScannerService.instance.barcodeStream.listen((barcode) {
  print('Scanned: $barcode');
});

// Disconnect
await ExternalBarcodeScannerService.instance.disconnectAll();
```

## Configuration

### Scanner Settings

**Input Timeout**: Time to wait for complete barcode (50-500ms)
- Lower = faster but may miss characters
- Higher = more reliable but slower

**Minimum Barcode Length**: Minimum characters for valid barcode (1-20)
- Prevents accidental scans
- Filters out noise

**Auto Submit**: Automatically process scanned barcodes
- Enabled = immediate processing
- Disabled = manual confirmation

### Connection Settings

**USB Vendor IDs**: Add custom vendor IDs for unsupported scanners
**Bluetooth Service UUIDs**: Configure custom service UUIDs
**WiFi Polling Interval**: How often to check for new scans (100-5000ms)

## Troubleshooting

### USB Scanner Not Detected

**Issue**: Scanner doesn't appear in device list

**Solutions**:
1. Check USB connection
2. Try different USB port
3. Restart browser
4. Check if scanner is in HID mode
5. Add vendor ID to filter list

### Bluetooth Connection Fails

**Issue**: Can't pair with Bluetooth scanner

**Solutions**:
1. Ensure scanner is in pairing mode
2. Check Bluetooth is enabled
3. Move scanner closer to computer
4. Clear browser Bluetooth cache
5. Use HTTPS (required for Web Bluetooth)

### WiFi Scanner Not Responding

**Issue**: No data from network scanner

**Solutions**:
1. Verify scanner IP address
2. Check network connectivity
3. Test endpoint with curl/browser
4. Check firewall settings
5. Ensure CORS is enabled on scanner

### Permission Denied

**Issue**: Browser blocks scanner access

**Solutions**:
1. Use HTTPS (required for Web APIs)
2. Grant permissions when prompted
3. Check browser settings
4. Clear site permissions and retry
5. Use supported browser

## Security Considerations

### HTTPS Required
- Web Bluetooth requires HTTPS
- WebUSB requires HTTPS
- Use localhost for development

### User Permissions
- User must explicitly grant access
- Permissions are per-origin
- Can be revoked in browser settings

### Data Privacy
- Barcode data stays in browser
- No external transmission
- Secure connection to scanners

## API Reference

### Connection Methods

```dart
// Bluetooth
Future<bool> connectBluetooth()
Future<void> disconnectBluetooth()

// USB
Future<bool> connectUsb()
Future<void> disconnectUsb()

// WiFi
Future<bool> connectWifi(String url)
void disconnectWifi()

// Disconnect all
Future<void> disconnectAll()
```

### Status Methods

```dart
// Check support
bool get isBluetoothSupported
bool get isUsbSupported

// Get connection type
ConnectionType get currentConnection
String getConnectionStatus()
```

### Data Stream

```dart
// Listen for barcodes
Stream<String> get barcodeStream

// Example
service.barcodeStream.listen((barcode) {
  print('Scanned: $barcode');
});
```

## Examples

### Example 1: USB Scanner

```dart
final service = ExternalBarcodeScannerService.instance;

// Check support
if (!service.isUsbSupported) {
  print('WebUSB not supported');
  return;
}

// Connect
final connected = await service.connectUsb();
if (!connected) {
  print('Failed to connect');
  return;
}

// Listen
service.barcodeStream.listen((barcode) {
  print('USB Scan: $barcode');
});
```

### Example 2: Bluetooth Scanner

```dart
final service = ExternalBarcodeScannerService.instance;

// Check support
if (!service.isBluetoothSupported) {
  print('Web Bluetooth not supported');
  return;
}

// Connect
final connected = await service.connectBluetooth();
if (!connected) {
  print('Failed to pair');
  return;
}

// Listen
service.barcodeStream.listen((barcode) {
  print('Bluetooth Scan: $barcode');
});
```

### Example 3: WiFi Scanner

```dart
final service = ExternalBarcodeScannerService.instance;

// Connect
final connected = await service.connectWifi('http://192.168.1.100');
if (!connected) {
  print('Scanner not reachable');
  return;
}

// Listen
service.barcodeStream.listen((barcode) {
  print('WiFi Scan: $barcode');
});
```

## Known Limitations

1. **Browser Support**: Limited to Chromium-based browsers for USB/Bluetooth
2. **HTTPS Required**: Web APIs require secure context
3. **User Interaction**: Connection must be triggered by user action
4. **Scanner Compatibility**: Not all scanners support Web APIs
5. **Network Scanners**: Requires custom API implementation

## Future Enhancements

- [ ] Auto-reconnection on disconnect
- [ ] Multiple scanner support
- [ ] Scanner profiles/presets
- [ ] Advanced filtering options
- [ ] Scan history
- [ ] Scanner diagnostics
- [ ] Firmware update support

## Resources

- **Web Bluetooth API**: https://developer.mozilla.org/en-US/docs/Web/API/Web_Bluetooth_API
- **WebUSB API**: https://developer.mozilla.org/en-US/docs/Web/API/WebUSB_API
- **Scanner Compatibility**: Check manufacturer documentation

---

**Last Updated**: 2025-12-09
**Status**: ✅ Implemented - Ready for testing
