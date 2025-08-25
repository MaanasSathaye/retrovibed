import 'package:flutter/material.dart' as m;

class Checkbox extends m.StatelessWidget {
  final bool value;
  final void Function(bool?)? onChanged;
  Checkbox({super.key, this.value = false, this.onChanged});

  @override
  m.Widget build(m.BuildContext context) {
    return m.Row(
      mainAxisSize: m.MainAxisSize.min,
      children: [
        m.Transform.translate(
          offset: const m.Offset(-8.0, 0.0), // Adjust this value as needed
          child: m.Checkbox(
            value: value,
            onChanged: onChanged,
            materialTapTargetSize: m.MaterialTapTargetSize.shrinkWrap,
            visualDensity: m.VisualDensity.compact,
          ),
        ),
        m.Spacer(),
      ],
    );
  }
}
