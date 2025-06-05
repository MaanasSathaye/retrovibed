import 'dart:io';
import 'dart:core';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:retrovibed/retrovibed.dart' as retro;

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
  return normalizeuri(Platform.environment["RETROVIBED_DAEMON_SOCKET"]) ??
      "localhost:9998";
}

String metaendpoint() {
  return normalizeuri(Platform.environment["RETROVIBED_META_ENDPOINT"]) ??
      "localhost:8081";
}

void set(String uri) {
  _host = uri;
}

// return an identity token for the local device.
String oauth2_bearer() {
  return "bearer ${retro.oauth2_bearer()}";
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

class Content {
  static Future<Request> json(Request request) {
    request.headers["Content-Type"] = "application/json";
    return Future.value(request);
  }

  static Future<Request> urlencoded(Request request) {
    request.headers["Content-Type"] = "application/x-www-form-urlencoded";
    return Future.value(request);
  }

  static Future<Request> formdata(Request request) {
    request.headers["Content-Type"] = "multipart/form-data";
    return Future.value(request);
  }
}

class Accept {
  static Future<Request> json(Request request) {
    request.headers["Accept"] = "application/json; charset=utf-8";
    return Future.value(request);
  }
}

typedef Option = Future<Request> Function(Request request);

class Request {
  Map<String, String> headers = {};

  static Future<Request> noop(Request request) {
    return Future.value(request);
  }

  static Option bearer(Future<String> token) {
    return (Request request) {
      return token.then((v) {
        if (v.isNotEmpty) {
          request.headers["Authorization"] = "Bearer ${v}";
        }
        return Future.value(request); // Returns a completed Future with the modified request
      });
    };
  }
}

Future<Request> request(List<Option> options) {
  return options.fold(Future.value(Request()), (Future<Request> p, Option opt) {
    return p.then((r) {
      return opt(r);
    });
  });
}

Future<http.Response> get(Uri path, {List<Option> options = const [], dynamic query = const {}}) {
  return request(options).then((r) {
    return http.Client().get(path, headers: r.headers).then(auto_error);
  });
}

Future<http.Response> post(Uri path, {List<Option> options = const []}) {
  return request(options).then((r) {
    return http.Client().post(path, headers: r.headers).then(auto_error);
  });
}