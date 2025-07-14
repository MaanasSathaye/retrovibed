import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;

class SearchTuning extends StatefulWidget {
  final media.DownloadSearchRequest current;
  final void Function(media.DownloadSearchRequest r) onChange;
  const SearchTuning(this.current, {super.key, required this.onChange});

  @override
  State<SearchTuning> createState() => _SearchTuningState();
}

class _SearchTuningState extends State<SearchTuning> {
  late media.DownloadSearchRequest _current;

  @override
  void initState() {
    super.initState();
    _current = widget.current.deepCopy();
  }

  @override
  void didUpdateWidget(covariant SearchTuning oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.current != oldWidget.current) {
      _current = widget.current.deepCopy();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mimetypes = mimex.checksum(_current.mimetypes);
    print("REBUILDING ${_current.hashCode}");
    return forms.Container(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(
            key: ValueKey(_current.hashCode),
            input: forms.Checkbox(
              value: _current.completed,
              onChanged: (v) {
                setState(() {
                  _current.completed = v ?? _current.completed;
                  widget.onChange(_current.deepCopy());
                });
              },
            ),
            label: Text("completed"),
          ),
        ],
      ),
    );
  }
}
