import 'package:flutter/material.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import './theme.defaults.dart';
import './buttons.dart';

class SearchTray extends StatelessWidget {
  static fixnum.Int64 Zero = fixnum.Int64.ZERO;

  static refocus(TextEditingController? controller) {
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
  final Widget tuning; // advance tuning widget
  final void Function(String i) onSubmitted;
  final void Function(fixnum.Int64 i) next;
  final fixnum.Int64 current;
  final bool empty;
  final bool autofocus;
  final bool disabled;
  final TextEditingController controller;
  final FocusNode? focus;
  final InputDecoration? inputDecoration;
  final ValueNotifier<Widget> tuningwidget = ValueNotifier(zerobox);

  SearchTray({
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
    tuning,
    TextEditingController? controller,
  }) : controller = controller ?? TextEditingController(),
       tuning = tuning ?? zerobox;

  @override
  Widget build(BuildContext context) {
    final theming = Defaults.of(context);
    print("DERP DERP ${tuningwidget.value == zerobox}");
    return Container(
      padding: theming.padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              leading,
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration:
                      inputDecoration ?? InputDecoration(hintText: "search"),
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
              buttons.refresh(onPressed: () => onSubmitted(controller.text)),
              buttons.settings(
                onPressed:
                    () =>
                        tuningwidget.value =
                            tuningwidget.value == zerobox ? tuning : zerobox,
              ),
              trailing,
            ],
          ),
          ValueListenableBuilder(
            valueListenable: tuningwidget,
            builder: (BuildContext context, Widget v, Widget? child) {
              return v;
            },
          ),
        ],
      ),
    );
  }
}
