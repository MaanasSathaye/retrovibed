import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import './theme.defaults.dart';
import './buttons.dart';

class SearchTray extends StatefulWidget {
  static fixnum.Int64 Zero = fixnum.Int64.ZERO;

  static void refocus(TextEditingController? controller) {
    if (controller == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: controller.text.length),
      );
    });
  }

  static Widget zerobox = const SizedBox();

  final Widget leading;
  final Widget trailing;
  final Widget tuning;
  final Future<void> Function(String i) onSubmitted;
  final void Function(fixnum.Int64 i) next;
  final fixnum.Int64 current;
  final bool empty;
  final bool autofocus;
  final bool disabled;
  final TextEditingController? controller;
  final FocusNode? focus;
  final InputDecoration? inputDecoration;

  const SearchTray({
    super.key,
    required this.onSubmitted,
    required this.next,
    required this.current,
    required this.empty,
    this.leading = const SizedBox(),
    this.trailing = const SizedBox(),
    this.autofocus = false,
    this.disabled = false,
    this.focus,
    this.inputDecoration,
    Widget? tuning,
    this.controller,
  }) : tuning = tuning ?? const SizedBox();

  @override
  State<SearchTray> createState() => _SearchTrayState();
}

class _SearchTrayState extends State<SearchTray> {
  final TextEditingController _defaultController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final ValueNotifier<Widget> _tuningwidget = ValueNotifier<Widget>(
    SearchTray.zerobox,
  );

  @override
  void dispose() {
    _defaultController.dispose();
    _focusNode.dispose();
    _tuningwidget.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theming = Defaults.of(context);

    return Container(
      padding: theming.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.leading,
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: theming.spacing ?? 0.0),
                  child: TextField(
                    controller: widget.controller ?? _defaultController,
                    decoration:
                        widget.inputDecoration ??
                        const InputDecoration(hintText: "search"),
                    autofocus: widget.autofocus,
                    focusNode: _focusNode,
                    onSubmitted: widget.onSubmitted,
                    enabled: !widget.disabled,
                  ),
                ),
              ),
              IconButton(
                onPressed:
                    widget.current == SearchTray.Zero
                        ? null
                        : () => widget.next(widget.current - 1),
                icon: const Icon(Icons.arrow_left),
              ),
              IconButton(
                onPressed:
                    widget.empty ? null : () => widget.next(widget.current + 1),
                icon: const Icon(Icons.arrow_right),
              ),
              buttons.refresh(
                onPressed:
                    () => widget.onSubmitted(
                      (widget.controller ?? _defaultController).text,
                    ),
              ),
              buttons.settings(
                onPressed:
                    () =>
                        _tuningwidget.value =
                            _tuningwidget.value == SearchTray.zerobox
                                ? widget.tuning
                                : SearchTray.zerobox,
              ),
              widget.trailing,
            ],
          ),
          ValueListenableBuilder<Widget>(
            valueListenable: _tuningwidget,
            builder: (BuildContext context, Widget v, Widget? child) {
              return v;
            },
          ),
        ],
      ),
    );
  }
}
