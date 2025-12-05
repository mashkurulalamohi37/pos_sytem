import 'dart:io';

class RestoreServiceFileImpl {
  static Future<String> readFile(String path) async {
    final file = File(path);
    return await file.readAsString();
  }
}

