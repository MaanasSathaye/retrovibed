import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/design.kit/forms.dart' as forms;

class MagnetDownloads extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(List<String>) onSubmitted;
  final StreamController<String> stream = StreamController<String>();

  MagnetDownloads({super.key, controller, required this.onSubmitted})
    : this.controller =
          controller ??
          TextEditingController(
            text:
                "magnet:?xt=urn:btih:f42f4f3181996ff4954dd5d7f166bc146810f8e3&dn=archlinux-2025.07.01-x86_64.iso",
          );

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
            controller.clear();
            ds.textediting.refocus(controller);
            focus.requestFocus();
          },
        ),
        ds.ErrorBoundary(
          ds.build((context) {
            return forms.ItemListManager<String>(
              stream: stream.stream,
              onSubmitted: (l) {
                onSubmitted([
                  if (controller.text.isNotEmpty) controller.text,
                  ...l,
                ]).catchError(ds.Error.boundary(context, null, ds.Error.unknown));
              },
              builder: (item) {
                return SelectionArea(
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}
