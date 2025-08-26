import 'package:flutter/material.dart';
import 'dart:ui' show lerpDouble;

class Defaults extends ThemeExtension<Defaults> {
  static const defaults = Defaults();

  static const _defaultSpacing = 10.0;
  static const _defaultPadding = EdgeInsets.all(16.0);
  static const _defaultMargin = EdgeInsets.all(5.0);
  static const _defaultDanger = Color.fromRGBO(110, 1, 1, 0.75);
  static const _defaultSuccess = Color.fromARGB(255, 0, 255, 17);
  static const _defaultOpaque = Color.fromRGBO(0, 0, 0, 0.80);
  static const _defaultBorder = Border.fromBorderSide(
    BorderSide(color: Color(0xFF000000)),
  );

  final double? _spacing;
  final EdgeInsets? _padding;
  final EdgeInsetsGeometry? _margin;
  final Border? _border;
  final Color? _danger;
  final Color? _success;
  final Color? _opaque;

  double get spacing => _spacing ?? _defaultSpacing;
  EdgeInsets get padding => _padding ?? _defaultPadding;
  EdgeInsetsGeometry get margin => _margin ?? _defaultMargin;
  Border get border => _border ?? _defaultBorder;
  Color get danger => _danger ?? _defaultDanger;
  Color get success => _success ?? _defaultSuccess;
  Color get opaque => _opaque ?? _defaultOpaque;

  // The constructor accepts nullable values to create partial instances.
  const Defaults({
    double? spacing,
    EdgeInsets? padding,
    EdgeInsetsGeometry? margin,
    Border? border,
    Color? danger,
    Color? success,
    Color? opaque,
  })  : _spacing = spacing,
        _padding = padding,
        _margin = margin,
        _border = border,
        _danger = danger,
        _success = success,
        _opaque = opaque;

  static Defaults of(BuildContext context) {
    return Theme.of(context).extension<Defaults>() ?? Defaults.defaults;
  }

  @override
  Defaults copyWith({
    double? spacing,
    EdgeInsets? padding,
    EdgeInsetsGeometry? margin,
    Border? border,
    Color? danger,
    Color? success,
    Color? opaque,
  }) {
    return Defaults(
      spacing: spacing ?? _spacing,
      padding: padding ?? _padding,
      margin: margin ?? _margin,
      border: border ?? _border,
      danger: danger ?? _danger,
      success: success ?? _success,
      opaque: opaque ?? _opaque,
    );
  }

  @override
  ThemeExtension<Defaults> lerp(
    covariant ThemeExtension<Defaults>? other,
    double t,
  ) {
    if (other is! Defaults) {
      return this;
    }

    return Defaults(
      spacing: lerpDouble(_spacing, other._spacing, t),
      padding: EdgeInsetsGeometry.lerp(_padding, other._padding, t) as EdgeInsets?,
      margin: EdgeInsetsGeometry.lerp(_margin, other._margin, t),
      border: Border.lerp(_border, other._border, t),
      danger: Color.lerp(_danger, other._danger, t),
      success: Color.lerp(_success, other._success, t),
      opaque: Color.lerp(_opaque, other._opaque, t),
    );
  }
}