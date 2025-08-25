import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'package:retrovibed/media.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart' as mediakit;
import 'package:retrovibed/mimex.dart' as mimex;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:path_provider/path_provider.dart';
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

Stream<mediakit.Media> range(BuildContext context, MediaSearchResponse i, Media pos) async* {
  final initial = i.items.sublist(
    max(i.items.indexWhere((m) => m.id == pos.id), 0),
  );

  for (var m in initial) {
    yield await PlayableMedia(m);
  }

  while (i.items.length == i.next.limit.toInt()) {
    i = await api.media.search(i.next, options: []);
    for (var m in i.items) {
      yield await PlayableMedia(m);
    }
    i.next..offset += 1;
  }

  // at this point we've run out of content from the provided search.
  // lets play random content. using things like the mimetypes from
  // from the initial request. we'll eventually add in more coherent
  // results to keep a trend going.
  while (true) {
    final v = await api.media.random(i.next,options: [authn.Authenticated.devicebearer(context)]);
    yield await PlayableMedia(v.media);
  }
}

Future<void> Function()? PlayAction(
  BuildContext context,
  Media current,
  MediaSearchResponse s,
) {
  switch (mimex.icon(current.mimetype)) {
    case mimex.movie:
    case mimex.audio:
      final playlist = Playlist.of(context);
      return playlist == null
          ? null
          : () {
            return Future.sync(() => playlist.setPlaylist(range(context, s, current)));
          };
    default:
      return null;
  }
}

Future<void> Function() DownloadAction(BuildContext context, Media current) {
  return () {
    return getDownloadsDirectory().then((downloads) {
      final sink = File('${downloads!.path}/${current.description.replaceAll(" ", ".")}').openWrite();
      return api.media
          .download(current.id, options: [authn.AuthzCache.bearer(context)])
          .then((resp) => resp.stream.pipe(sink));
    });
  };
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
