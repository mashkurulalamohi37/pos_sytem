// Web implementation - file reading handled differently
class RestoreServiceFileImpl {
  static Future<String> readFile(String path) async {
    // This should not be called on web
    throw UnsupportedError('File reading not supported on web');
  }
}

