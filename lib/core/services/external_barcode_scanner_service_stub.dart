// Stub implementation for non-web platforms
library external_barcode_scanner_service_stub;

/// Stub implementation of HTML document operations for non-web platforms
class HtmlDocument {
  void addEventListener(String event, dynamic Function(Event)? handler, [bool useCapture = false]) {
    // No-op on non-web platforms
  }

  void removeEventListener(String event, dynamic Function(Event)? handler, [bool useCapture = false]) {
    // No-op on non-web platforms
  }

  dynamic querySelector(String selector) {
    // Returns null on non-web platforms
    return null;
  }
}

/// Stub Event class for non-web platforms
class Event {
  // Stub event - not used on non-web platforms
}

/// Stub KeyboardEvent class for non-web platforms
class KeyboardEvent extends Event {
  String? key;
}

// Export to match web implementation
final HtmlDocument document = HtmlDocument();

