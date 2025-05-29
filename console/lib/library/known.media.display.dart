import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/media/media.pb.dart';
import './api.dart' as api;

class KnownMediaDisplay extends StatefulWidget {
  final Future<api.Known> pending;
  final GestureTapCallback? onDoubleTap;
  final void Function()? onSettings;
  final Widget? trailing;

  const KnownMediaDisplay(
    this.pending, {
    super.key,
    this.onDoubleTap,
    this.onSettings,
    this.trailing,
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
          summary: "no metadata known, feel free to assign",
          rating: 0.0,
          image: "",
        ),
      ),
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
    final defaults = ds.Defaults.of(context);

    return ds.Card(
      onDoubleTap: widget.onDoubleTap,
      leading: Center(
        child: Text(
          current.description,
          overflow: TextOverflow.fade,
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
          padding: defaults.padding ?? EdgeInsets.all(0.0),
          child: Text(current.summary, textAlign: TextAlign.start),
        ),
      ),
      trailing:
          widget.trailing ??
          Row(
            children: [
              Flexible(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: Center(child: ds.Rating(rating: current.rating)),
                ),
              ),
              Spacer(flex: 9),
              IconButton(
                onPressed: widget.onSettings,
                // onPressed: () {
                //   ds.modals
                //       .of(context)
                //       ?.push(
                //           Flexible(
                //             child: Center(
                //               child: SizedBox(
                //                 height: 512,
                //                 width: 1024,
                //                 child: KnownMediaDropdown(
                //                   current: current.id,
                //                 ),
                //               ),
                //             ),
                //           ),
                //       );
                // },
                icon: Icon(Icons.tune),
              ),
            ],
          ),
    );
  }
}
