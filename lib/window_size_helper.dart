import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

void setupWindowSize() {
  // Set minimum window size
  setWindowMinSize(const Size(1024, 768));
  
  // Set window title
  setWindowTitle('Aronium POS');
  
  // Set initial window size
  setWindowFrame(Rect.fromCenter(
    center: Offset.zero,
    width: 1280,
    height: 800,
  ));
}
