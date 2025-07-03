import 'package:flutter/material.dart' as material;
import 'package:retrovibed/designkit.dart' as ds;

class Card extends material.StatelessWidget {
  final material.Widget leading;
  final material.Widget image;
  final material.Widget child;
  final material.Widget trailing;

  final material.EdgeInsets? margin;

  final material.GestureTapCallback? onTap;
  final material.GestureTapCallback? onDoubleTap;
  final material.GestureLongPressCallback? onLongPress;

  const Card({
    required this.image,
    required this.child,
    this.leading = const material.SizedBox(),
    this.trailing = const material.SizedBox(),
    this.onTap,
    this.onDoubleTap,
    this.onLongPress,
    this.margin,
  });

  @override
  material.Widget build(material.BuildContext context) {
    final defaults = ds.Defaults.of(context);
    return material.InkWell(
      onTap: onTap,
      onDoubleTap: onDoubleTap,
      onLongPress: onLongPress,
      child: material.Card(
        margin: margin ?? defaults.margin,
        child: material.Container(
          alignment: material.Alignment.center,
          padding: defaults.padding ?? material.EdgeInsets.zero,
          child: material.Column(
            children: [
              material.Padding(
                padding: material.EdgeInsets.only(top: 0.0, bottom: 10.0),
                child: leading,
              ),
              material.Expanded(
                child: material.Row(
                  mainAxisSize: material.MainAxisSize.min,
                  children: [
                    image,
                    material.Expanded(
                      child: material.SelectionArea(child: child),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
