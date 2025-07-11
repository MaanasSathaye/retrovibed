import 'package:flutter/material.dart';

class Field extends StatelessWidget {
  final Widget? label;
  final Widget input;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry? margin;

  Field({
    super.key,
    required this.input,
    this.label,
    this.constraints = const BoxConstraints(maxHeight: 48.0, minHeight: 48.0),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      child: ConstrainedBox(
        constraints: constraints,
        child: Row(
          children: [
            if (label != null) Expanded(child: label!),
            Expanded(child: input, flex: 9),
          ],
        ),
      ),
    );
  }
}
