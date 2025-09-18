const isRunningWithWasm = bool.fromEnvironment('dart.tool.dart2wasm');

bool get rendererCanvasKit => isRunningWithWasm;
