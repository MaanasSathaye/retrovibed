import 'package:flutter/material.dart';
import './overlay.dart' as s;

class Loading extends StatelessWidget {
  static const Widget Icon = const Center(
    child: const CircularProgressIndicator(
      backgroundColor: Color.fromARGB(0, 0, 0, 0),
      semanticsLabel: 'Linear progress indicator',
    ),
  );

  static Widget Sized({double? width, double? height}) {
    return Container(width: width, height: height, child: Icon);
  }

  final Widget? child;
  final bool loading;
  final Widget overlay;
  final Widget? cause;

  const Loading(
    this.child, {
    super.key,
    this.overlay = Loading.Icon,
    this.loading = false,
    this.cause = null,
  });

  @override
  Widget build(BuildContext context) {
    return s.Overlay(
      Visibility(
        visible: !loading,
        maintainState: true, // Key: Keeps the state of widget.child when it's not visible
        child: child ?? const SizedBox(), // The subtree you want to preserve
      ),
      overlay: loading ? overlay : cause,
    );
  }
}
