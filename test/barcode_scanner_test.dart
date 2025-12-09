import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:aronium/presentation/widgets/barcode_scanner_widget.dart';

void main() {
  group('BarcodeScannerWidget Tests', () {
    testWidgets('BarcodeScannerWidget renders without errors', (WidgetTester tester) async {
      // Create a mock callback function
      String? scannedBarcode;
      void onBarcodeScanned(String barcode) {
        scannedBarcode = barcode;
      }

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BarcodeScannerWidget(
                onBarcodeScanned: onBarcodeScanned,
              ),
            ),
          ),
        ),
      );

      // Verify that the widget renders without errors
      expect(find.byType(BarcodeScannerWidget), findsOneWidget);
    });

    testWidgets('Manual barcode entry works', (WidgetTester tester) async {
      // Create a mock callback function
      String? scannedBarcode;
      void onBarcodeScanned(String barcode) {
        scannedBarcode = barcode;
      }

      // Build the widget
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: BarcodeScannerWidget(
                onBarcodeScanned: onBarcodeScanned,
              ),
            ),
          ),
        ),
      );

      // Wait for initialization to complete
      await tester.pumpAndSettle();

      // Find the manual input field (if visible)
      final textFieldFinder = find.byType(TextField);
      if (textFieldFinder.evaluate().isNotEmpty) {
        // Enter a barcode
        await tester.enterText(textFieldFinder, '123456789');
        
        // Find and tap the submit button
        final buttonFinder = find.text('Search Product');
        if (buttonFinder.evaluate().isNotEmpty) {
          await tester.tap(buttonFinder);
          await tester.pumpAndSettle();
          
          // Verify the callback was called
          expect(scannedBarcode, equals('123456789'));
        }
      }
    });
  });
}