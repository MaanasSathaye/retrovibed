import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './theme.defaults.dart';
import './screens.dart' as screens;

NodeState? of(BuildContext context) {
  return Node.of(context);
}

class Node extends StatefulWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const Node(this.child, {super.key, this.alignment = Alignment.center});

  static NodeState? of(BuildContext context) {
    return context.findAncestorStateOfType<NodeState>();
  }

  @override
  State<StatefulWidget> createState() => NodeState();
}

class NodeState extends State<Node> {
  final FocusNode _selffocus = FocusNode();
  Widget? current;

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void push(Widget? m) {
    setState(() {
      current = m;
    });
    _selffocus.requestFocus();
  }

  void reset() {
    print("modal reset called");
    setState(() {
      current = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themex = Defaults.of(context);
    final mq = MediaQuery.of(context);
    return screens.Overlay.tappable(
      widget.child,
      overlay:
          current == null
              ? null
              : KeyboardListener(
                focusNode: _selffocus,
                onKeyEvent: (event) {
                  if (event is KeyDownEvent) {
                    return;
                  }

                  if (event.logicalKey == LogicalKeyboardKey.escape) {
                    push(null);
                  }
                },
                child: Container(
                  height: mq.size.height,
                  width: mq.size.width,
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor.withValues(
                      alpha: themex.opaque?.a ?? 0.0,
                    ),
                  ),
                  child: Center(child: SingleChildScrollView(child: current!)),
                ),
              ),
      alignment: widget.alignment,
      onTap: current != null ? reset : null,
    );
  }
}
