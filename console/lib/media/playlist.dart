import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:language_code/language_code.dart';

import 'dart:collection';

class RingBuffer<T> {
  final ListQueue<T> _queue;
  final int capacity;

  RingBuffer(this.capacity)
    : assert(capacity > 0),
      _queue = ListQueue<T>(
        capacity,
      ); // Pre-allocate with capacity for efficiency

  int get length => _queue.length;
  bool get isEmpty => _queue.isEmpty;
  bool get isFull => _queue.length == capacity;

  /// Returns a new List containing all elements in the buffer, from oldest to newest.
  List<T> toList() {
    return _queue.toList();
  }

  /// Adds an element to the buffer. If the buffer is full,
  /// the oldest element is removed first to make space.
  void insert(T? element) {
    if (element == null) return;
    if (isFull) {
      _queue.removeFirst(); // Remove the oldest element
    }
    _queue.addLast(element); // Add the new element
  }

  /// Removes and returns the oldest element from the buffer.
  T? remove() {
    if (isEmpty) {
      return null;
    }
    return _queue.removeLast();
  }

  /// Returns the oldest element without removing it.
  T? peek() {
    return _queue.lastOrNull;
  }

  /// Clears all elements from the buffer.
  void clear() {
    _queue.clear();
  }
}

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
}

class _PlaylistState extends State<Playlist> {
  final TextEditingController controller = TextEditingController();
  final FocusNode searchfocus = FocusNode();
  final FocusNode _selffocus = FocusNode();
  final player = Player();

  StreamIterator<Media> upcoming = StreamIterator(Stream.empty());
  Media? current;
  RingBuffer<Media> _upcoming = RingBuffer(128);
  RingBuffer<Media> _previous = RingBuffer(128);

  @override
  void initState() {
    super.initState();
    player.stream.tracks.listen((track) {
      final current = LanguageCode.code;
      final matches = track.audio.where((t) {
        final code = LanguageCodes.fromCode(
          t.language ?? "",
          orElse: () => LanguageCodes.aa,
        );
        return current.englishName.startsWith(code.englishName);
      });

      final audio = matches.firstOrNull ?? AudioTrack.auto();
      final subtitles =
          audio.id != AudioTrack.auto().id
              ? SubtitleTrack.no()
              : track.subtitle.where((t) {
                    final code = LanguageCodes.fromCode(
                      t.language ?? "",
                      orElse: () => LanguageCodes.aa,
                    );
                    return current.englishName.startsWith(code.englishName);
                  }).firstOrNull ??
                  SubtitleTrack.no();
      player.setAudioTrack(audio);
      player.setSubtitleTrack(subtitles);

      // print(
      //   "current: ${current} ${LanguageCode.locale} ${LanguageCode.code.englishName}",
      // );
      // print("audio: ${audio.id} ${audio.language} ${audio.title} -- ${audio}");
      // print(
      //   "subtitles: ${subtitles.id} ${subtitles.language} ${subtitles.title} -- ${subtitles}",
      // );
    });
    // player.stream.playlist.listen((list) {
    //   print("playlist: ${list.index} - ${list}");
    // });

    player.stream.error.listen((err) {
      print("error: ${err}");
    });

    player.stream.completed.listen((completed) {
      if (!completed) return;

      print(
        "advancing through playlist ${player.state.playlist.medias.length} ${player.state.playlist.medias}",
      );
      completed ? next() : player.pause();
    });

    player.stream.playing.listen((playing) {
      if (playing) return;
      _selffocus.requestFocus();
      searchfocus.requestFocus();
    });
  }

  void setPlaylist(Stream<Media> pl) {
    print("set playlist invoked");
    upcoming = StreamIterator(pl);
    _upcoming.clear();
    next();
  }

  void next() {
    print(
      "next initiated: ${_previous.toList().length} | ${current?.extras?["title"]} | ${_upcoming.toList().length}",
    );
    _advance().whenComplete(() {
      print(
        "next completed: ${_previous.toList().length} | ${current?.extras?["title"]} | ${_upcoming.toList().length}",
      );
    });
  }

  void previous() {
    print(
      "previous initiated: ${_previous.toList().length} | ${current?.extras?["title"]} | ${_upcoming.toList().length}",
    );
    _reverse().then((m) {
      print(
        "previous completed: ${_previous.toList().length} | ${current?.extras?["title"]} | ${_upcoming.toList().length}",
      );
    });
  }

  Future<Media?> _reverse() {
    final prev = _previous.remove();
    if (prev == null) return Future.value(null);
    return player.open(prev).then((_) {
      _upcoming.insert(current);
      current = prev;
      return current;
    });
  }

  Future<Media?> _advance() {
    return Future<Media?>.value(
          _upcoming.remove() ??
              upcoming.moveNext().then((next) {
                return next ? upcoming.current : null;
              }),
        )
        .then((m) {
          if (m == null) return Future.value(null);
          return player.open(m).then((_) {
            _previous.insert(current);
            current = m;
            return m;
          });
        })
        .then((m) {
          if (m != null) return;
          print("end of media reached");
        })
        .catchError((cause) {
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
    return Focus(
      canRequestFocus: true,
      autofocus: true,
      focusNode: _selffocus,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          return KeyEventResult.ignored;
        }

        if (event.logicalKey != LogicalKeyboardKey.escape) {
          return KeyEventResult.ignored;
        }

        player.playOrPause();
        return KeyEventResult.handled;
      },
      child: widget.child,
    );
  }
}
