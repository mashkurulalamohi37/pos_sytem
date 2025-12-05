import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:convert';

/// File helper implementation for Android
/// Creates a JSON file and shares it properly
class FileHelperImpl {
  static Future<void> saveAndShare({
    required String content,
    required String fileName,
    String? subject,
  }) async {
    try {
      // Get external storage directory (more accessible for sharing)
      // Try external storage first, fallback to app documents
      Directory? directory;
      try {
        // Try to get external storage directory
        directory = await getExternalStorageDirectory();
      } catch (e) {
        // Fallback to application documents directory
        directory = await getApplicationDocumentsDirectory();
      }
      
      if (directory == null) {
        // Last resort: use temporary directory
        directory = await getTemporaryDirectory();
      }
      
      final filePath = '${directory.path}/$fileName';
      
      // Write content to file as UTF-8
      final file = File(filePath);
      await file.writeAsString(content, encoding: utf8);
      
      // Verify file exists and has content
      if (!await file.exists()) {
        throw Exception('Failed to create backup file');
      }
      
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('Backup file is empty');
      }
      
      // Read file as bytes (required for Android/iOS sharing)
      final bytes = await file.readAsBytes();
      
      // Ensure file name has .json extension
      final jsonFileName = fileName.endsWith('.json') ? fileName : '$fileName.json';
      
      // Create XFile from bytes with proper MIME type and file name
      // This is the recommended way for Android/iOS
      final xFile = XFile.fromData(
        bytes,
        name: jsonFileName,
        mimeType: 'application/json',
      );
      
      // Share the file using bytes
      // Include a note in the text to help users save it correctly
      await Share.shareXFiles(
        [xFile],
        text: '${subject ?? 'Aronium POS Backup'}\n\nPlease save this file with the .json extension to restore it later.',
        subject: subject,
      );
      
      // Note: Don't delete the file immediately - let the user access it
      // The file will be cleaned up by the system or can be manually deleted
    } catch (e) {
      // If file sharing fails, try reading as bytes and using fromData
      try {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final xFile = XFile.fromData(
            bytes,
            name: fileName,
            mimeType: 'application/json',
          );
          
          await Share.shareXFiles(
            [xFile],
            text: subject ?? 'Aronium POS Backup',
            subject: subject,
          );
        } else {
          throw Exception('File not found: $e');
        }
      } catch (e2) {
        // Last resort: share as text
        await Share.share(
          content,
          subject: subject ?? 'Aronium POS Backup - $fileName',
        );
      }
    }
  }
}

