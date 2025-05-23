import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:retrovibed/designkit.dart' as ds;

class SearchTray extends StatelessWidget {
  static fixnum.Int64 Zero = fixnum.Int64.ZERO;

  static refocus(TextEditingController? controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller == null) return;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }
  
  final Widget trailing;
  final void Function(String i) onSubmitted;
  final void Function(fixnum.Int64 i) next;
  final fixnum.Int64 current;
  final bool empty;
  final bool autofocus;
  final bool disabled;
  final TextEditingController? controller;
  final FocusNode? focus;
  final InputDecoration? inputDecoration;

  SearchTray({
    super.key,
    required this.onSubmitted,
    required this.next,
    required this.current,
    required this.empty,
    this.trailing = const SizedBox(),
    this.autofocus = false,
    this.disabled = false,
    this.controller,
    this.focus,
    this.inputDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final theming = ds.Defaults.of(context);
    return Container(
      padding: theming.padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: inputDecoration ?? InputDecoration(hintText: "search"),
              autofocus: autofocus,
              focusNode: focus,
              onSubmitted: onSubmitted,
              enabled: !disabled,
            ),
          ),
          IconButton(
            onPressed: current == 0 ? null : () => next(current + 1),
            icon: Icon(Icons.arrow_left),
          ),
          IconButton(
            onPressed: empty ? null : () => next(current + 1),
            icon: Icon(Icons.arrow_right),
          ),
          trailing,
        ],
      ),
    );
  }
}
