import 'package:flutter/material.dart';
import './overlay.dart' as s;

class Loading extends StatelessWidget {
  static const Widget Icon = const Center(
    child: CircularProgressIndicator(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      semanticsLabel: 'Linear progress indicator',
    ),
  );

  final Widget? child;
  final bool loading;
  final Widget overlay;
  final Widget? cause;

  const Loading(this.child, {
    super.key,
    this.overlay = const Center(child: Loading.Icon),
    this.loading = false,
    this.cause = null,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(child: overlay, alignment: Alignment.center);
    }

    return s.Overlay(child: child ?? const SizedBox(), overlay: cause);
  }
}
