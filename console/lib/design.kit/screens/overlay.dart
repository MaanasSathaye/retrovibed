import 'package:flutter/material.dart';

class Overlay extends StatelessWidget {
  final Widget child;
  final Widget? overlay;
  final AlignmentGeometry alignment;
  final Function()? onTap;

  const Overlay(
    this.child, {
    super.key,
    this.overlay,
    this.alignment = Alignment.center,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: alignment,
      children: [
        InkWell(onTap: onTap, child: child),
        overlay ?? const SizedBox(),
      ],
    );
  }
}
