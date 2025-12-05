import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

/// File helper implementation for desktop platforms (Windows/macOS/Linux)
class FileHelperImpl {
  static Future<void> saveAndShare({
    required String content,
    required String fileName,
    String? subject,
  }) async {
    try {
      // On desktop, let user choose where to save the file
      String? outputPath = await FilePicker.platform.saveFile(
        dialogTitle: subject ?? 'Save File',
        fileName: fileName,
      );
      
      if (outputPath == null) {
        // User cancelled the picker
        return;
      }
      
      // Write the file
      final file = File(outputPath);
      await file.writeAsString(content);
      
      // Optional: Open the file or containing folder
      // For Windows, we could use Process.run('explorer', ['/select,', outputPath]);
      // But this is platform-specific and may require additional checks
    } catch (e) {
      throw Exception('Failed to save file: $e');
    }
  }
}
