import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/sku_settings_provider.dart';
import '../../../data/services/sku_generator_service.dart';

class SkuSettingsScreen extends ConsumerStatefulWidget {
  const SkuSettingsScreen({super.key});

  @override
  ConsumerState<SkuSettingsScreen> createState() => _SkuSettingsScreenState();
}

class _SkuSettingsScreenState extends ConsumerState<SkuSettingsScreen> {
  late TextEditingController _patternController;
  late bool _autoGenerate;
  String _previewSku = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(skuSettingsProvider);
    _patternController = TextEditingController(text: settings.pattern);
    _autoGenerate = settings.autoGenerate;
    _updatePreview();
  }

  @override
  void dispose() {
    _patternController.dispose();
    super.dispose();
  }

  void _updatePreview() {
    final pattern = _patternController.text;
    
    setState(() {
      _previewSku = SkuGeneratorService.generateSku(
        pattern: pattern,
        productName: 'Sample Product',
        categoryPrefix: 'ELEC',
        sequentialNumber: 42,
      );
    });
  }

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(skuSettingsProvider.notifier).saveSettings(
        pattern: _patternController.text,
        autoGenerate: _autoGenerate,
      );
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('SKU settings saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving settings: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _resetSequentialNumber() async {
    setState(() => _isLoading = true);
    
    try {
      await ref.read(skuSettingsProvider.notifier).resetSequentialNumber();
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sequential number reset successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error resetting sequential number: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lastSequentialNumber = ref.watch(skuSettingsProvider).lastSequentialNumber;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SKU Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Pattern explanation
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SKU Pattern',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You can use the following placeholders in your SKU pattern:',
                  ),
                  const SizedBox(height: 12),
                  _buildPlaceholderRow('{category}', 'Category prefix (if available)'),
                  _buildPlaceholderRow('{name}', 'Product name prefix'),
                  _buildPlaceholderRow('{random}', 'Random alphanumeric string'),
                  _buildPlaceholderRow('{number}', 'Sequential number'),
                  _buildPlaceholderRow('{date}', 'Current date (YYYYMMDD)'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Pattern input
          TextFormField(
            controller: _patternController,
            decoration: InputDecoration(
              labelText: 'SKU Pattern',
              hintText: 'e.g., {category}-{name}-{number}',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            onChanged: (_) => _updatePreview(),
          ),
          const SizedBox(height: 16),
          
          // Preview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _previewSku,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
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
          const SizedBox(height: 16),
          
          // Auto-generate option
          Card(
            child: SwitchListTile(
              title: const Text('Auto-generate SKUs'),
              subtitle: const Text('Automatically generate SKUs for new products'),
              value: _autoGenerate,
              onChanged: (value) {
                setState(() {
                  _autoGenerate = value;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          
          // Sequential number info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sequential Number',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current value: $lastSequentialNumber',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Next SKU will use: {number} = ${(lastSequentialNumber + 1).toString().padLeft(4, '0')}',
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Sequential Number'),
                    onPressed: _isLoading ? null : _resetSequentialNumber,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Save button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Save Settings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPlaceholderRow(String placeholder, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Text(
              placeholder,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(description)),
        ],
      ),
    );
  }
}
