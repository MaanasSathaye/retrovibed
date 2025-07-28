import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/media.dart' as media;

class MediaEdit extends StatelessWidget {
  final media.Media current;
  final Function(Future<media.Media>) onChange;
  final EdgeInsetsGeometry? padding;
  MediaEdit({
    super.key,
    required this.current,
    required this.onChange,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theming = Theme.of(context);

    return Container(
      padding: padding,
      color: theming.scaffoldBackgroundColor,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(
            label: Text("description"),
            input: TextFormField(
              initialValue: current.description,
              onChanged:
                  (v) => onChange(Future.value(current..description = v)),
            ),
          ),
        ],
      ),
    );
  }
}
