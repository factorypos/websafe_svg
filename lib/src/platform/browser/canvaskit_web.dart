import 'dart:js' as js;

bool get rendererCanvasKit => js.context['flutterCanvasKit'] != null;
