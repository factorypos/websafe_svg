// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:websafe_svg/src/platform/browser/browser_svg_loader.dart';
import 'package:websafe_svg/src/platform/browser/canvaskit_stub.dart' if (dart.library.html) 'canvaskit_web.dart' as c_kit;

class BrowserSvg extends StatefulWidget {
  const BrowserSvg({
    required this.alignment,
    this.allowDrawingOutsideViewBox = false,
    this.clipBehavior = Clip.hardEdge,
    this.colorFilter,
    required this.excludeFromSemantics,
    required this.fit,
    required this.height,
    super.key,
    required this.loader,
    this.matchTextDirection = false,
    required this.placeholderBuilder,
    required this.semanticsLabel,
    this.theme,
    required this.width,
  });

  final Alignment alignment;
  final bool allowDrawingOutsideViewBox;
  final Clip clipBehavior;
  final ColorFilter? colorFilter;
  final bool excludeFromSemantics;
  final BoxFit fit;
  final double? height;
  final BrowserSvgLoader loader;
  final bool matchTextDirection;
  final WidgetBuilder? placeholderBuilder;
  final String? semanticsLabel;
  final SvgTheme? theme;
  final double? width;

  @override
  State createState() => _BrowserSvgState();
}

class _BrowserSvgState extends State<BrowserSvg> {
  static final Logger _logger = Logger('_BrowserSvgState');

  int _loadIndex = 0;
  String? _image;
  Uint8List? _imageBytes;
  late BrowserSvgLoader _loader;

  bool get rendererCanvasKit => c_kit.rendererCanvasKit;

  @override
  void initState() {
    super.initState();

    _loader = widget.loader;
    _loadImage();
  }

  @override
  void didUpdateWidget(BrowserSvg oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.loader != oldWidget.loader) {
      _loader = widget.loader;
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (mounted == true) {
      setState(() {});
    }
    _loadIndex++;
    final idx = _loadIndex;

    try {
      var image = await _loader.load();

      if (idx == _loadIndex) {
        _imageBytes = Uint8List.fromList(utf8.encode(image));
        final b64 = base64.encode(_imageBytes!.toList());
        image = 'data:image/svg+xml;base64,$b64';

        _image = image;

        if (mounted == true) {
          setState(() {});
        }
      }
    } catch (e, stack) {
      _logger.info('Error loading SVG', e, stack);
    }
  }

  Widget _buildPlaceholder(BuildContext context) =>
      widget.placeholderBuilder == null ? const SizedBox() : Builder(builder: widget.placeholderBuilder!);

  @override
  Widget build(BuildContext context) {
    final colorFilter = widget.colorFilter;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: _image == null
          ? _buildPlaceholder(context)
          : rendererCanvasKit
              ? SvgPicture.memory(
                  _imageBytes!,
                  alignment: widget.alignment,
                  allowDrawingOutsideViewBox: widget.allowDrawingOutsideViewBox,
                  clipBehavior: widget.clipBehavior,
                  colorFilter: widget.colorFilter,
                  fit: widget.fit,
                  height: widget.height,
                  matchTextDirection: widget.matchTextDirection,
                  semanticsLabel: widget.semanticsLabel,
                  theme: widget.theme ?? const SvgTheme(),
                  width: widget.width,
                )
              : Container(
                  height: widget.height,
                  width: widget.width,
                  alignment: widget.alignment,
                  child: colorFilter == null
                      ? Image.network(
                          _image!,
                          alignment: widget.alignment,
                          height: widget.height,
                          fit: widget.fit,
                          semanticLabel: widget.semanticsLabel,
                          width: widget.width,
                        )
                      : ColorFiltered(
                          colorFilter: colorFilter,
                          child: Image.network(
                            _image!,
                            alignment: widget.alignment,
                            height: widget.height,
                            fit: widget.fit,
                            semanticLabel: widget.semanticsLabel,
                            width: widget.width,
                          ),
                        ),
                ),
    );
  }
}
