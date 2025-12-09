import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/external_barcode_scanner_service.dart';

class BarcodeScannerSettingsWidget extends StatefulWidget {
  const BarcodeScannerSettingsWidget({super.key});

  @override
  State<BarcodeScannerSettingsWidget> createState() => _BarcodeScannerSettingsWidgetState();
}

class _BarcodeScannerSettingsWidgetState extends State<BarcodeScannerSettingsWidget> {
  bool _externalScannerEnabled = false;
  bool _externalScannerConnected = false;
  bool _isChecking = false;
  bool _isLoading = true;
  bool _isSaving = false;
  int _inputTimeout = 100; // milliseconds
  int _minBarcodeLength = 3;
  bool _autoSubmit = true;
  String _lastScannedBarcode = '';
  StreamSubscription<String>? _testSubscription;
  Timer? _testTimeoutTimer;

  // Settings keys
  static const String _keyEnabled = 'barcode_scanner_enabled';
  static const String _keyInputTimeout = 'barcode_scanner_input_timeout';
  static const String _keyMinLength = 'barcode_scanner_min_length';
  static const String _keyAutoSubmit = 'barcode_scanner_auto_submit';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _testSubscription?.cancel();
    _testTimeoutTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    if (!kIsWeb) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Load from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool(_keyEnabled) ?? false;
      final inputTimeout = prefs.getInt(_keyInputTimeout) ?? 100;
      final minLength = prefs.getInt(_keyMinLength) ?? 3;
      final autoSubmit = prefs.getBool(_keyAutoSubmit) ?? true;

      // Check scanner connection
      final isConnected = await ExternalBarcodeScannerService.instance.isScannerConnected();

      // Update service config
      final config = BarcodeScannerConfig(
        enabled: enabled && isConnected,
        inputTimeout: inputTimeout,
        minBarcodeLength: minLength,
        autoSubmit: autoSubmit,
      );
      ExternalBarcodeScannerService.instance.updateConfig(config);

      if (mounted) {
        setState(() {
          _externalScannerEnabled = enabled;
          _externalScannerConnected = isConnected;
          _inputTimeout = inputTimeout;
          _minBarcodeLength = minLength;
          _autoSubmit = autoSubmit;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    if (!kIsWeb) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait([
        prefs.setBool(_keyEnabled, _externalScannerEnabled),
        prefs.setInt(_keyInputTimeout, _inputTimeout),
        prefs.setInt(_keyMinLength, _minBarcodeLength),
        prefs.setBool(_keyAutoSubmit, _autoSubmit),
      ]);

      // Update service config
      final config = BarcodeScannerConfig(
        enabled: _externalScannerEnabled && _externalScannerConnected,
        inputTimeout: _inputTimeout,
        minBarcodeLength: _minBarcodeLength,
        autoSubmit: _autoSubmit,
      );
      ExternalBarcodeScannerService.instance.updateConfig(config);

      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings saved successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkForScanners() async {
    setState(() => _isChecking = true);

    try {
      final isConnected = await ExternalBarcodeScannerService.instance.isScannerConnected();

      if (mounted) {
        setState(() {
          _externalScannerConnected = isConnected;
          _isChecking = false;
        });

        // Update service config if enabled
        if (_externalScannerEnabled && isConnected) {
          final config = BarcodeScannerConfig(
            enabled: true,
            inputTimeout: _inputTimeout,
            minBarcodeLength: _minBarcodeLength,
            autoSubmit: _autoSubmit,
          );
          ExternalBarcodeScannerService.instance.updateConfig(config);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isConnected
                  ? 'Scanner ready! Most barcode scanners work as keyboard devices.'
                  : 'No scanner detected. Connect a USB or Bluetooth scanner and try again.',
            ),
            backgroundColor: isConnected ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking for scanners: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _testScanner() {
    if (!_externalScannerEnabled || !_externalScannerConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enable the scanner first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    String? scannedBarcode;
    bool isScanning = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          // Set up timeout
          _testTimeoutTimer?.cancel();
          _testTimeoutTimer = Timer(const Duration(seconds: 30), () {
            if (isScanning && context.mounted) {
              setDialogState(() => isScanning = false);
              _testSubscription?.cancel();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Test timeout. No barcode was scanned.'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          });

          // Listen for barcode
          _testSubscription?.cancel();
          _testSubscription = ExternalBarcodeScannerService.instance.barcodeStream.listen(
            (barcode) {
              if (isScanning) {
                setDialogState(() {
                  scannedBarcode = barcode;
                  isScanning = false;
                });
                _testSubscription?.cancel();
                _testTimeoutTimer?.cancel();
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully scanned: $barcode'),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            onError: (error) {
              if (isScanning && context.mounted) {
                setDialogState(() => isScanning = false);
                _testSubscription?.cancel();
                _testTimeoutTimer?.cancel();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error during scan: $error'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          );

          return AlertDialog(
            title: Row(
              children: [
                const Icon(Icons.qr_code_scanner, color: Colors.blue),
                const SizedBox(width: 8),
                const Text('Test Scanner'),
              ],
            ),
            content: SizedBox(
              width: 300,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isScanning) ...[
                    const Text(
                      'Scan a barcode with your external scanner:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.blue.withOpacity(0.05),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.qr_code_scanner, size: 64, color: Colors.blue),
                          const SizedBox(height: 16),
                          const Text(
                            'Waiting for scan...',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.blue.withOpacity(0.7),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else if (scannedBarcode != null) ...[
                    const Icon(Icons.check_circle, size: 64, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Barcode Scanned!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        scannedBarcode!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _testSubscription?.cancel();
                  _testTimeoutTimer?.cancel();
                  Navigator.pop(context);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onSettingChanged() {
    // Auto-save when settings change
    _saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Barcode Scanner Settings'),
        ),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Scanner settings are only available on web platform.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Barcode Scanner Settings'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Barcode Scanner Settings'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: 'Save Settings',
              onPressed: _saveSettings,
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Scanner Status Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _externalScannerConnected
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _externalScannerConnected
                                  ? Icons.scanner
                                  : Icons.scanner_outlined,
                              color: _externalScannerConnected ? Colors.green : Colors.grey,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'External Scanner Status',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: _externalScannerConnected
                                            ? Colors.green
                                            : Colors.grey,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _externalScannerConnected
                                          ? 'Ready'
                                          : 'Not Connected',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: _externalScannerConnected
                                            ? Colors.green
                                            : Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _isChecking ? null : _checkForScanners,
                              icon: _isChecking
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Icon(Icons.refresh),
                              label: Text(_isChecking ? 'Checking...' : 'Check for Scanners'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_externalScannerConnected) ...[
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: _externalScannerEnabled ? _testScanner : null,
                              icon: const Icon(Icons.qr_code_scanner),
                              label: const Text('Test'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Scanner Settings Card
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Scanner Settings',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Enable/Disable Scanner
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Enable External Scanner',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: const Text(
                          'Allow external barcode scanner input',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: _externalScannerEnabled,
                        onChanged: _externalScannerConnected
                            ? (value) {
                                setState(() {
                                  _externalScannerEnabled = value;
                                });
                                _onSettingChanged();
                              }
                            : null,
                      ),

                      const Divider(),
                      const SizedBox(height: 8),

                      // Input Timeout
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Input Timeout',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_inputTimeout ms',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Slider(
                              value: _inputTimeout.toDouble(),
                              min: 50,
                              max: 500,
                              divisions: 9,
                              label: '$_inputTimeout ms',
                              onChanged: (value) {
                                setState(() {
                                  _inputTimeout = value.round();
                                });
                                _onSettingChanged();
                              },
                            ),
                            const Text(
                              'Time to wait for complete barcode input',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),
                      const SizedBox(height: 8),

                      // Minimum Barcode Length
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Minimum Barcode Length',
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_minBarcodeLength',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Slider(
                              value: _minBarcodeLength.toDouble(),
                              min: 1,
                              max: 20,
                              divisions: 19,
                              label: '$_minBarcodeLength',
                              onChanged: (value) {
                                setState(() {
                                  _minBarcodeLength = value.round();
                                });
                                _onSettingChanged();
                              },
                            ),
                            const Text(
                              'Minimum number of characters for a valid barcode',
                              style: TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      const Divider(),
                      const SizedBox(height: 8),

                      // Auto Submit
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text(
                          'Auto Submit',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: const Text(
                          'Automatically process scanned barcodes',
                          style: TextStyle(fontSize: 13),
                        ),
                        value: _autoSubmit,
                        onChanged: (value) {
                          setState(() {
                            _autoSubmit = value;
                          });
                          _onSettingChanged();
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Instructions Card
              Card(
                elevation: 2,
                color: Colors.blue.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instructions',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInstructionItem(
                        '1',
                        'Connect your USB or Bluetooth barcode scanner to your computer',
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        '2',
                        'Click "Check for Scanners" to verify the device is ready',
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        '3',
                        'Enable the external scanner option to start listening',
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        '4',
                        'Test the scanner to ensure it\'s working properly',
                      ),
                      const SizedBox(height: 12),
                      _buildInstructionItem(
                        '5',
                        'Adjust settings as needed for your specific scanner model',
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.lightbulb_outline,
                              size: 20,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Note: Most barcode scanners work as HID keyboard devices '
                                'and will automatically input barcodes when scanned. '
                                'Make sure your scanner is configured to send an Enter key after each scan.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
      ],
    );
  }
}
