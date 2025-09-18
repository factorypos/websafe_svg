import 'package:flutter/material.dart';

late BuildContext context;

extension JsDummy on BuildContext {
  String? operator [](String other) {
    return null;
  }

  void callMethod(dynamic1, dynamic2) {}
}
