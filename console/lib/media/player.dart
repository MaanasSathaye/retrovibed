import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:media_kit_video/media_kit_video.dart';
import 'package:retrovibed/designkit.dart' as ds;
import './playlist.dart' as internal;

class VideoScreen extends StatefulWidget {
  final Widget child;
  final Player player;
  const VideoScreen(this.child, this.player, {Key? key}) : super(key: key);

  static _VideoState? of(BuildContext context) {
    return context.findAncestorStateOfType<_VideoState>();
  }

  @override
  State<VideoScreen> createState() => _VideoState();
}

class _VideoState extends State<VideoScreen> {
  bool _playing = false;

  // Create a [VideoController] to handle video output from [Player].
  late final controller = VideoController(widget.player);
 late final StreamSubscription<bool> sub0; 
  late final StreamSubscription<bool> sub1;

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void add(Media m) {
    widget.player.add(m).then((v) {
      widget.player.next();
    });
  }

  @override
  void initState() {
    super.initState();

    // sub0 = widget.player.stream.track.listen((state) {
    //   setState(() {});
    // });

    sub1 = widget.player.stream.playing.listen((state) {
      setState(() {
        _playing = state;
      });
    });
  }

  @override
  void dispose() {
    sub1.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themex = ds.Defaults.of(context);
    var plist = internal.Playlist.of(context);
    var title = plist?.current?.extras?["title"] ?? "";

    final m =
        _playing
            ? SizedBox()
            : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor.withValues(
                        alpha: themex.opaque?.a ?? 0.0,
                      ),
                    ),
                    child: widget.child,
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                  ),
                  child:
                      plist?.current == null
                          ? SizedBox()
                          : IconButton(
                            onPressed: () {
                              widget.player.play();
                            },
                            icon: Row(
                              spacing: 10.0,
                              children: [
                                Icon(Icons.play_circle_outline_rounded),
                                Text("Resume ${title}"),
                              ],
                            ),
                          ),
                ),
              ],
            );

    return Stack(
      children: [
        MaterialDesktopVideoControlsTheme(
          normal: MaterialDesktopVideoControlsThemeData(
            bottomButtonBar: [
              IconButton(
                onPressed: () {
                  internal.Playlist.of(context)?.previous();
                },
                icon: Icon(Icons.skip_previous_rounded),
              ),
              MaterialPlayOrPauseButton(),
              IconButton(
                onPressed: () {
                  internal.Playlist.of(context)?.next();
                },
                icon: Icon(Icons.skip_next_rounded),
              ),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              Spacer(),
              MaterialPositionIndicator(),
              MaterialFullscreenButton(),
            ],
          ),
          fullscreen: MaterialDesktopVideoControlsThemeData(
            bottomButtonBar: [
              IconButton(
                onPressed: () {
                  internal.Playlist.of(context)?.previous();
                },
                icon: Icon(Icons.skip_previous_rounded),
              ),
              MaterialPlayOrPauseButton(),
              IconButton(
                onPressed: () {
                  internal.Playlist.of(context)?.next();
                },
                icon: Icon(Icons.skip_next_rounded),
              ),
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
              Spacer(),
              MaterialPositionIndicator(),
              MaterialFullscreenButton(),
            ],
          ),
          child: Video(controller: controller),
        ),
        m,
      ],
    );
  }
}
