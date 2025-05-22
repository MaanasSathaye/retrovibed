import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:language_code/language_code.dart';

class Playlist extends StatefulWidget {
  final Widget child;

  const Playlist(this.child, {Key? key}) : super(key: key);

  static _PlaylistState? of(BuildContext context) {
    return context.findAncestorStateOfType<_PlaylistState>();
  }

  @override
  State<Playlist> createState() => _PlaylistState();

  static Widget wrap(
    Widget Function(BuildContext context, _PlaylistState s) b,
  ) {
    return Builder(
      builder: (context) {
        final _PlaylistState? current = Playlist.of(context);
        // if we don't have a playlist ancestor thats a bug.
        return b(context, current!);
      },
    );
  }

  static playlist(Iterable<Media> playlist) {

  }
}

class _PlaylistState extends State<Playlist> {
  final TextEditingController controller = TextEditingController();
  final FocusNode searchfocus = FocusNode();
  final FocusNode _selffocus = FocusNode();
  final player = Player();
  StreamIterator<Media> playlist = StreamIterator(Stream.empty());

  @override
  void initState() {
    super.initState();
    player.setAudioTrack(AudioTrack.auto());
    player.stream.tracks.listen((track) {
      final current = LanguageCode.locale.toLanguageTag();
      // track.audio.forEach((t) => print("audio: ${t.id} ${t.language} ${t.title} -- ${t}"));
      // track.subtitle.forEach((t) => print("subtitle: ${t.id} ${t.language} ${t.title} -- ${t}"));
      final audio = track.audio.firstWhere((t) => t.language == current, orElse: () => AudioTrack.auto());
      final subtitles = audio.language == current ? SubtitleTrack.no() : track.subtitle.firstWhere((t) => t.language == current, orElse: () => SubtitleTrack.no());
      player.setAudioTrack(audio);
      player.setSubtitleTrack(subtitles);

      print("audio: ${audio.id} ${audio.language} ${audio.title} -- ${audio}");
      print("subtitles: ${subtitles.id} ${subtitles.language} ${subtitles.title} -- ${subtitles}");
    });
    player.stream.completed.listen((completed) {
      if (!completed) {return;}
      print("advancing through playlist ${player.state.playlist.medias.length} ${player.state.playlist.medias}");

      player.remove(0).then((_) {
        _advance();
      }).catchError((cause) {
        print("unable to advance stream ${cause}");
      }).ignore();
    });

    player.stream.playing.listen((playing) {
      if (playing) return;
      _selffocus.requestFocus();
      searchfocus.requestFocus();
    });
  }

  void setPlaylist(Stream<Media> pl) {
    playlist = StreamIterator(pl);
    _advance();
  }

  void _advance() {
    playlist.moveNext().then((next) {
      return player.add(playlist.current).then((v) {
        return player.next();
      });
    }).catchError((cause) {
      print("unable to pull next media from playlist ${cause}");
    });
  }

  @override
  void dispose() {
    super.dispose();
    player.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _selffocus,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          return;
        }

        if (event.logicalKey == LogicalKeyboardKey.escape) {
          player.playOrPause();
        }
      },
      child: widget.child,
    );
  }
}
