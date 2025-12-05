import 'package:flutter/foundation.dart' show kIsWeb;

// Conditional imports - use separate implementations
// Web first, then mobile as default (not desktop!)
import 'file_helper_io.dart'  // Default for mobile (Android/iOS) 
  if (dart.library.html) 'file_helper_web.dart'  // Web
  as file_impl;

// Import Platform for runtime checks (only on non-web)
import 'dart:io' show Platform
  if (dart.library.html) 'file_helper_web.dart';  // Stub for web

// Import desktop for runtime check (only on non-web, non-mobile)
import 'file_helper_desktop.dart' as desktop_impl
  if (dart.library.html) 'file_helper_web.dart';  // Stub for web

/// Platform-agnostic file sharing helper
class FileHelper {
  /// Save content to a file and share it
  /// On web, shares the content directly as text
  /// On mobile, saves to a file and shares the file
  static Future<void> saveAndShare({
    required String content,
    required String fileName,
    String? subject,
  }) async {
    if (kIsWeb) {
      // Web platform
      await file_impl.FileHelperImpl.saveAndShare(
        content: content,
        fileName: fileName,
        subject: subject,
      );
    } else {
      // Non-web: Check if mobile or desktop
      try {
        if (Platform.isAndroid || Platform.isIOS) {
          // Mobile platforms - use mobile implementation
          await file_impl.FileHelperImpl.saveAndShare(
            content: content,
            fileName: fileName,
            subject: subject,
          );
        } else {
          // Desktop platforms (Windows, macOS, Linux)
          await desktop_impl.FileHelperImpl.saveAndShare(
            content: content,
            fileName: fileName,
            subject: subject,
          );
        }
      } catch (e) {
        // Fallback to mobile implementation if Platform check fails
        await file_impl.FileHelperImpl.saveAndShare(
          content: content,
          fileName: fileName,
          subject: subject,
        );
      }
    }
  }
}