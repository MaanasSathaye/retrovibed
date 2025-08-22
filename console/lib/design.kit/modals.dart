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
  static const zeromodal = const SizedBox();
  final FocusNode _selffocus = FocusNode(debugLabel: "modal.node");
  Widget current = zeromodal;
  List<Widget> stack = [];

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void push(Widget? m) {
    setState(() {
      _selffocus.requestFocus();
      if (m == null) {
        setState(() {
          current = stack.isEmpty ? zeromodal : stack.last;
          stack.remove(current);
        });
        return;
      }

      setState(() {
        if (current == NodeState.zeromodal) {
          current = m;
          return;
        }

        stack = stack + [current];
        current = m;
      });
    });
  }

  void reset() {
    setState(() {
      current = zeromodal;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themex = Defaults.of(context);
    final mq = MediaQuery.of(context);

    return screens.Overlay.tappable(
      widget.child,
      overlay: Focus(
        canRequestFocus: true,
        autofocus: true,
        focusNode: _selffocus,
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent) {
            return KeyEventResult.ignored;
          }
          if (event.logicalKey != LogicalKeyboardKey.escape || (stack.isEmpty && current == NodeState.zeromodal)) {
            return KeyEventResult.ignored;
          }

          push(null);
          return KeyEventResult.handled;
        },
        child: Visibility(
          visible: current != zeromodal,
          child: Container(
            height: mq.size.height,
            width: mq.size.width,
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(
                alpha: themex.opaque?.a ?? 0.0,
              ),
            ),
            child: SingleChildScrollView(child: current),
          ),
        ),
      ),
      alignment: widget.alignment,
      onTap: current != zeromodal ? reset : null,
    );
  }
}
