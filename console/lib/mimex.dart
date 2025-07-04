import 'package:flutter/material.dart';
import 'package:mime/mime.dart' as mimetype;
export 'package:mime/mime.dart';

final resolver =
    mimetype.MimeTypeResolver()
      ..addMagicNumber([0x4F, 0x67, 0x67, 0x53], "video/ogg");

String fromFile(String s, {List<int>? magicbits}) {
  return maybe(resolver.lookup(s, headerBytes: magicbits));
}

String maybe(String? s) {
  return s ?? "application/octet-stream";
}

const movie = Icons.movie;
const audio = Icons.music_note_outlined;
const binary = Icons.file_open_outlined;

int checksumfor(IconData v) {
  final movied = checksum(["video/ogg"]);
  final audiod = checksum(["audio/"]);

  if (v == movie) {
    return movied;
  }

  if (v == audio) {
    return audiod;
  }

  return -1;
}

int checksum(List<String> mimes) {
  return Object.hashAllUnordered(mimes);
}

IconData icon(String mimetype) {
  if (mimetype.startsWith('video/')) {
    return movie;
  }

  if (mimetype.startsWith('audio/')) {
    return audio;
  }

  return binary;
}
