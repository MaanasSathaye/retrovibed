import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void _notimplemented(String s) {
  return print(s);
}

void defaulttap() => _notimplemented("tap not implemented");

Future<T> defaulttapfn<T>(T v) {
  _notimplemented("tap not implemented");
  return Future.value(v);
}

Future<void> defaulttapv() =>
    Future.sync(() => _notimplemented("tap not implemented"));

class bytesx {
  static const int KiB = 1024;
  static const int MiB = 1048576;
  static const int GiB = 1073741824;
  static const int TiB = 1099511627776;

  static const Map<int, String> _valueToStringMap = {
    KiB: 'KiB',
    MiB: 'MiB',
    GiB: 'GiB',
    TiB: 'TiB',
  };

  static String getName(int value) {
    return _valueToStringMap[value] ?? "";
  }
}

class ByteWidget extends StatefulWidget {
  final ValueChanged<int>? onChange;
  final int value;
  final int magnitude;
  final InputDecoration? decoration;

  const ByteWidget({
    super.key,
    this.onChange,
    this.value = 0,
    this.magnitude = bytesx.GiB,
    this.decoration,
  });

  @override
  State<ByteWidget> createState() => _ByteInputWidgetState(
    bytes: value,
    magnitude: magnitude,
    decoration: decoration,
  );
}

class _ByteInputWidgetState extends State<ByteWidget> {
  final TextEditingController _controller;
  int _magnitude;
  int _bytes;
  final InputDecoration? _decoration;

  _ByteInputWidgetState({
    required int bytes,
    required int magnitude,
    required InputDecoration? decoration,
  }) : _bytes = bytes,
       _magnitude = magnitude,
       _decoration = decoration,
       _controller = TextEditingController(text: bytes.toStringAsFixed(0));

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateBytes);
    // final v = _bytes * _magnitude;
    // widget.onChange?.call(v);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateBytes);
    _controller.dispose();
    super.dispose();
  }

  void _updateBytes() {
    final text = _controller.text;
    final int? parsed = int.tryParse(text);

    if (parsed == null) {
      return;
    }

    setState(() {
      _bytes = parsed;
    });
    final v = _bytes * _magnitude;
    widget.onChange?.call(v);
  }

  @override
  void reassemble() {
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            keyboardType: TextInputType.number, // Shows numeric keyboard
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly, // Allows only digits
            ],
            decoration:
                _decoration
          ),
        ),
        const SizedBox(width: 8),
        DropdownButton<int>(
          value: _magnitude,
          onChanged: (v) {
            setState(() {
              _magnitude = v ?? _magnitude;
            });
            final int y = (_bytes * _magnitude);
            widget.onChange?.call(y);
          },
          items:
              [bytesx.KiB, bytesx.MiB, bytesx.GiB, bytesx.TiB].map((
                int magnitude,
              ) {
                return DropdownMenuItem<int>(
                  value: magnitude,
                  child: Text(bytesx.getName(magnitude)),
                );
              }).toList(),
        ),
      ],
    );
  }
}
