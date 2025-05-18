import 'dart:math';
import 'package:console/media.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as mediakit;
import 'package:console/mimex.dart' as mimex;
import 'package:console/httpx.dart' as httpx;
import './api.dart' as api;

mediakit.Media PlayableMedia(Media current) {
  return mediakit.Media(
    api.media.download_uri(current.id),
    extras: Map.of(<String, String>{
      "id": current.id,
      "title": current.description,
    }),
    httpHeaders: <String, String>{"Authorization": httpx.auto_bearer_host()},
  );
}

Stream<mediakit.Media> range(MediaSearchResponse i, Media pos) async* {
  final initial = i.items.sublist(max(i.items.indexWhere((m) => m.id == pos.id), 0));
  for (var m in initial) {
    yield await PlayableMedia(m);
  }

  while (i.items.length == i.next.limit.toInt()) {
    i = await api.media.get(i.next);
    for (var m in i.items) {
      yield await PlayableMedia(m);
    }
    i.next..offset += 1;
  }
}

void Function()? PlayAction(BuildContext context, Media current, MediaSearchResponse s) {
  switch (mimex.icon(current.mimetype)) {
    case mimex.movie:
    case mimex.audio:
      final playlist = Playlist.of(context);
      return playlist == null ? null : () {
        playlist.setPlaylist(range(s, current));
      };
    default:
      return null;
  }
}

class ButtonPlay extends StatelessWidget {
  final Media current;
  final MediaSearchResponse playlist;
  const ButtonPlay({super.key, required this.current, required this.playlist});

  @override
  Widget build(BuildContext context) {
    switch (mimex.icon(current.mimetype)) {
      case mimex.movie:
      case mimex.audio:
        return IconButton(
          icon: Icon(Icons.play_circle_outline_rounded),
          onPressed: PlayAction(context, current, playlist),
        );
      default:
        return Container();
    }
  }
}
