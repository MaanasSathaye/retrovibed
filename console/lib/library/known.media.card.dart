import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import './api.dart' as api;

class KnownMediaCard extends StatelessWidget {
  final api.Known current;
  final GestureTapCallback? onDoubleTap;
  final Widget? trailing;

  const KnownMediaCard(
    this.current, {
    super.key,
    this.onDoubleTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);
    return ds.Card(
      onDoubleTap: onDoubleTap,
      leading: Center(
        child: Text(
          current.description,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      image: AspectRatio(
        aspectRatio: 27 / 40,
        child: Opacity(
          opacity: 0.25,
          child: SizedBox.expand(
            child:
                current.image == ""
                    ? Icon(Icons.image_outlined, size: 128)
                    : Image.network(current.image),
          ),
        ),
      ),
      child: Container(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: defaults.padding ?? EdgeInsets.zero,
          child: Text(current.summary, textAlign: TextAlign.start),
        ),
      ),
      trailing: trailing ?? SizedBox(),
    );
  }
}
