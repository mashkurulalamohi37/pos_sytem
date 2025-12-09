// Web-specific implementation
library external_barcode_scanner_service_web;

import 'dart:html' as html;

// Re-export document and event types
final HtmlDocument document = HtmlDocument._();

class HtmlDocument {
  HtmlDocument._();
  
  void addEventListener(String type, dynamic Function(html.Event)? listener, [bool useCapture = false]) {
    html.document.addEventListener(type, listener, useCapture);
  }
  
  void removeEventListener(String type, dynamic Function(html.Event)? listener, [bool useCapture = false]) {
    html.document.removeEventListener(type, listener, useCapture);
  }
  
  dynamic querySelector(String selectors) {
    return html.document.querySelector(selectors);
  }
}

typedef Event = html.Event;
typedef KeyboardEvent = html.KeyboardEvent;

