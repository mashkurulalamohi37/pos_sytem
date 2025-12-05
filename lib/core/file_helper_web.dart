import 'dart:html' as html;
import 'dart:convert';

/// File helper implementation for web platform
class FileHelperImpl {
  static Future<void> saveAndShare({
    required String content,
    required String fileName,
    String? subject,
  }) async {
    try {
      // For web, create a downloadable blob
      final bytes = utf8.encode(content);
      final blob = html.Blob([bytes], 'application/json');
      final url = html.Url.createObjectUrlFromBlob(blob);
      
      // Create and trigger download
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', fileName)
        ..style.display = 'none';
      
      html.document.body?.append(anchor);
      anchor.click();
      
      // Wait a bit to ensure download starts
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Clean up after download starts
      Future.delayed(const Duration(milliseconds: 500), () {
        try {
          anchor.remove();
          html.Url.revokeObjectUrl(url);
        } catch (e) {
          // Ignore cleanup errors
        }
      });
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }
}

