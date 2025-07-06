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

List<String> of(IconData v) {
  if (v == movie) {
    return [
      "video/mp4",
      "video/webm",
      "video/ogg",
      "video/mpeg",
      "video/x-msvideo",
      "video/x-ms-wmv",
      "video/3gpp",
      "video/3gpp2",
      "video/quicktime",
      "video/mp2t",
      "video/x-flv",
      "video/x-matroska",
      "video/x-dv",
      "video/fli",
      "video/x-fli",
      "video/gl",
      "video/x-gl",
      "video/x-ms-asf",
      "video/avi",
      "video/msvideo",
      "video/avs-video",
      "video/dl",
      "video/x-dl",
      "video/animaflex",
    ];
  }

  if (v == audio) {
    return [
      "audio/aac",
      "audio/midi",
      "audio/x-midi",
      "audio/mpeg",
      "audio/mp3", // Common alias, though audio/mpeg is more standard for MP3
      "audio/mp4",
      "audio/ogg",
      "audio/opus",
      "audio/wav",
      "audio/x-wav",
      "audio/aiff",
      "audio/x-aiff",
      "audio/x-m4a",
      "audio/basic",
      "audio/vnd.rn-realaudio",
      "audio/x-mpegurl", // For .m3u playlists
      "audio/flac",
      "audio/amr",
      "audio/vnd.dolby.mlp",
      "audio/vnd.dts",
      "audio/vnd.dts.hd",
      "audio/vnd.nuera.ecelp4800",
      "audio/vnd.nuera.ecelp7470",
      "audio/vnd.nuera.ecelp9600",
      "audio/vnd.qcelp",
      "audio/g729",
      "audio/ilbc",
      "audio/x-gsm",
      "audio/x-pn-wav",
      "audio/x-smpte336m",
      "audio/adpcm",
      "audio/3gpp",
      "audio/3gpp2",
      "audio/vnd.wave", // Alias for audio/wav
    ];
  }

  return [];
}

int checksumfor(IconData v) {
  return checksum(of(v));
}

int checksum(List<String> mimes) {
  if (mimes.isEmpty) return -1;
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
