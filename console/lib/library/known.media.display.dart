import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/library/known.media.card.dart';
import 'package:retrovibed/media/media.pb.dart';
import 'package:retrovibed/media.dart' as _media;
import './api.dart' as api;

class KnownMediaDisplay extends StatefulWidget {
  final Future<api.Known> pending;
  final _media.Media media;
  final GestureTapCallback? onDoubleTap;
  final void Function()? onSettings;
  final Widget? trailing;

  const KnownMediaDisplay(
    this.pending, {
    super.key,
    this.onDoubleTap,
    this.onSettings,
    this.trailing,
    required this.media,
  });

  static KnownMediaDisplay missing(
    Media m, {
    GestureTapCallback? onDoubleTap,
    void Function()? onSettings,
  }) {
    return KnownMediaDisplay(
      Future.value(
        api.Known(
          id: "",
          description: m.description,
          summary: "",
          rating: 0.0,
          image: "",
        ),
      ),
      media: m,
      key: ValueKey(m.id),
      onDoubleTap: onDoubleTap,
      onSettings: onSettings,
    );
  }

  static _KnownMediaDisplayState? of(BuildContext context) {
    return context.findAncestorStateOfType<_KnownMediaDisplayState>();
  }

  @override
  State<StatefulWidget> createState() => _KnownMediaDisplayState();
}

class _KnownMediaDisplayState extends State<KnownMediaDisplay> {
  api.Known current = api.Known(
    id: "",
    description: "",
    summary: "",
    rating: 0.0,
    image: "",
  );

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    widget.pending.then((v) {
      setState(() {
        current = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return KnownMediaCard(
      current,
      onDoubleTap: widget.onDoubleTap,
      trailing: Row(
        children: [
          Flexible(
            flex: 4,
            child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Center(child: ds.Rating(rating: current.rating)),
            ),
          ),
          Spacer(flex: 8),
          ds.LoadingIconButton(onPressed: _media.DownloadAction(context, widget.media), icon: Icon(Icons.download)),
          IconButton(onPressed: widget.onSettings, icon: Icon(Icons.tune)),
        ],
      ),
    );
  }
}
