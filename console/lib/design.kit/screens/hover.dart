import 'package:flutter/material.dart' as material;
import './overlay.dart';

class Hover extends material.StatefulWidget {
  static const _zero = const material.SizedBox();
  final material.Widget child;
  final material.Widget overlay;

  final material.EdgeInsets? margin;

  const Hover(this.child, {super.key, required this.overlay, this.margin});

  @override
  material.State<Hover> createState() => _HoverState();
}

class _HoverState extends material.State<Hover> {
  material.Widget? disabled = Hover._zero;

  @override
  void setState(material.VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  material.Widget build(material.BuildContext context) {
    return material.MouseRegion(
      onEnter:
          (event) => setState(() {
            disabled = null;
          }),
      onExit:
          (event) => setState(() {
            disabled = Hover._zero;
          }),
      child: Overlay(
        disabled == null
            ? material.Opacity(opacity: 0.05, child: widget.child)
            : widget.child,
        overlay: disabled ?? widget.overlay,
      ),
    );
  }
}
