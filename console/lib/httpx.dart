import 'dart:io';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:console/retrovibed.dart' as retro;

var _host = localhost();

String host() {
  return _host;
}

String? normalizeuri(String? s) {
  if (s == null) return s;
  final uri = Uri.parse(s);
  return "${uri.host}:${uri.port}";
}

String localhost() {
  return normalizeuri(Platform.environment["RETROVIBED_DAEMON_SOCKET"]) ?? "localhost:9998";
}

void set(String uri) {
  _host = uri;
}

// return an identity token for the local device.
String auto_bearer() {
  return "bearer ${retro.bearer_token()}";
}

// return a identity token from the currently connected host.
String auto_bearer_host({String? host}) {
  final token = retro.bearer_token_host("https://${host ?? _host}");
  return token.isEmpty ? "" : "bearer ${token}";
}

abstract class mimetypes {
  static MediaType parse(String s) {
    try {
      return MediaType.parse(s);
    } catch (e) {
      print(
        "failed to parse mimetype ${s} ${e} returning application/octet-stream",
      );
      return MediaType("application", "octet-stream");
    }
  }

  static MediaType maybe(String? s) {
    if (s == null) return MediaType("application", "octet-stream");
    return parse(s);
  }
}

Future<http.MultipartFile> uploadable(
  String path,
  String name,
  String mimetype, {
  String field = 'content',
}) {
  return http.MultipartFile.fromPath(
    field,
    path,
    filename: name,
    contentType: mimetypes.parse(mimetype),
  );
}

Future<http.Response> auto_error(http.Response v) {
  if (v.statusCode >= 300) {
    print("failed ${v.request?.url.toString()} ${v.statusCode}");
  }

  return v.statusCode >= 300 ? Future.error(v) : Future.value(v);
}

class ErrorsTest {
  static bool badrequest(Object obj) {
    return obj is http.Response && obj.statusCode == 400;
  }

  static bool unauthorized(Object obj) {
    return obj is http.Response && obj.statusCode == 401;
  }

  static bool forbidden(Object obj) {
    return obj is http.Response && obj.statusCode == 403;
  }

  static bool err404(Object obj) {
    return obj is http.Response && obj.statusCode == 404;
  }
}
