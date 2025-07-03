import 'package:flutter/material.dart';

class Overlay extends StatelessWidget {
  final Widget child;
  final Widget? overlay;
  final AlignmentGeometry alignment;
  final Function()? onTap;

  const Overlay({
    super.key,
    required this.child,
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
        // Positioned.fill(child: overlay ?? const SizedBox())
        overlay ?? const SizedBox(),
      ],
    );
  }
}
