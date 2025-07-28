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
    final poster =
        current.image == ""
            ? Icon(Icons.image_outlined, size: 128)
            : Image.network(current.image);
    return ds.Card(
      AspectRatio(
        aspectRatio: 2 / 3,
        child: SizedBox.expand(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12.0),
            child: ds.Hover(
              poster,
              overlay: Container(
                alignment: Alignment.topLeft,
                padding: defaults.padding ?? EdgeInsets.zero,
                child: Column(
                  children: [
                    Text(
                      current.summary,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      maxLines: 10,
                    ),
                    Spacer(flex: 9),
                    trailing ?? const SizedBox(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      onDoubleTap: onDoubleTap,
      leading: Center(
        child: Text(
          current.description,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
