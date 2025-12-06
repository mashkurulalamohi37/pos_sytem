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
      
      // Determine file extension and MIME type based on fileName
      String finalFileName = fileName;
      String mimeType;
      
      if (fileName.toLowerCase().endsWith('.csv')) {
        mimeType = 'text/csv';
        finalFileName = fileName;
      } else if (fileName.toLowerCase().endsWith('.json')) {
        mimeType = 'application/json';
        finalFileName = fileName;
      } else {
        // Default to CSV if no extension, or use the provided extension
        if (!fileName.contains('.')) {
          finalFileName = '$fileName.csv';
          mimeType = 'text/csv';
        } else {
          // Try to detect from extension
          final ext = fileName.split('.').last.toLowerCase();
          if (ext == 'csv') {
            mimeType = 'text/csv';
          } else if (ext == 'json') {
            mimeType = 'application/json';
          } else {
            mimeType = 'text/plain';
          }
        }
      }
      
      // Create XFile from bytes with proper MIME type and file name
      // This is the recommended way for Android/iOS
      final xFile = XFile.fromData(
        bytes,
        name: finalFileName,
        mimeType: mimeType,
      );
      
      // Share the file using bytes
      // Include a note in the text to help users save it correctly
      final fileType = finalFileName.endsWith('.csv') ? 'CSV' : 'JSON';
      await Share.shareXFiles(
        [xFile],
        text: '${subject ?? 'Aronium POS Report'}\n\nPlease save this $fileType file to open it later.',
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
          
          // Determine MIME type from file extension
          String mimeType = 'text/plain';
          if (fileName.toLowerCase().endsWith('.csv')) {
            mimeType = 'text/csv';
          } else if (fileName.toLowerCase().endsWith('.json')) {
            mimeType = 'application/json';
          }
          
          final xFile = XFile.fromData(
            bytes,
            name: fileName,
            mimeType: mimeType,
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

