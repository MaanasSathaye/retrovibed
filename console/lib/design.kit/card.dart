import 'package:flutter/material.dart' as material;
import 'package:retrovibed/designkit.dart' as ds;

class Card extends material.StatelessWidget {
  final material.Widget leading;
  final material.Widget child;
  final material.Widget trailing;

  final material.EdgeInsets? margin;

  final material.GestureTapCallback? onTap;
  final material.GestureTapCallback? onDoubleTap;
  final material.GestureLongPressCallback? onLongPress;

  const Card(this.child, {
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
          padding: defaults.padding,
          child: material.Column(
            children: [
              material.Container(
                margin: material.EdgeInsets.only(bottom: defaults.margin.vertical),
                child: leading,
              ),
              material.Expanded(
                child: material.SelectionArea(child: child),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
