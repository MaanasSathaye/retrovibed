import 'package:flutter/material.dart';

class Overlay extends StatelessWidget {
  final Widget child;
  final Widget? overlay;
  final AlignmentGeometry alignment;

  const Overlay(
    this.child, {
    super.key,
    this.overlay,
    this.alignment = Alignment.center,
  });

  factory Overlay.tappable(
    Widget child, {
    Key? key,
    Widget? overlay,
    AlignmentGeometry alignment = Alignment.center,
    required Function()? onTap,
  }) {
    return Overlay(
      onTap == null ? child : InkWell(onTap: onTap, child: child),
      key: key,
      alignment: alignment,
      overlay: overlay,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: alignment,
      children: [
        child,
        overlay ?? const SizedBox(),
      ],
    );
  }
}
