import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/forms.dart' as forms;

class MagnetDownloads extends StatelessWidget {
  final TextEditingController? controller;
  final Function(List<String>) onSubmitted;
  final StreamController<String> stream = StreamController<String>();

  MagnetDownloads({super.key, this.controller, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final focus = FocusNode();
    final defaults = ds.Defaults.of(context);
    return Column(
      spacing: defaults.spacing ?? 0.0,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          focusNode: focus,
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Enter an magnet link',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) {
            stream.add(v);
            controller?.clear();
            ds.textediting.refocus(controller);
            focus.requestFocus();
          },
        ),
        forms.ItemListManager<String>(
          stream: stream.stream,
          onSubmitted: onSubmitted,
          builder: (item) {
            return SelectionArea(
              child: Text(item, maxLines: 1, overflow: TextOverflow.ellipsis),
            );
          },
        ),
      ],
    );
  }
}
