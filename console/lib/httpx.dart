import 'dart:io';
import 'dart:core';
import 'dart:convert';
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
  // return "localhost:8081";
  return normalizeuri(Platform.environment["RETROVIBED_META_ENDPOINT"]) ??
      "api.retrovibe.space";
}

String consoleendpoint() {
  // return "localhost:8080";
  return "console.retrovibe.space";
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

Future<T> auto_error<T extends http.BaseResponse>(T v) {
  if (v.statusCode >= 300) {
    print("failed ${v.request?.url.toString()} ${v.statusCode}");
  }

  return v.statusCode >= 300 ? Future.error(v) : Future.value(v);
}

Future<HttpClientResponse> dart_io_auto_error(HttpClientRequest v) {
  return v.close().then((r) {
    if (r.statusCode >= 300) {
      print("failed ${v.uri.toString()} ${r.statusCode}");
    }

    return r.statusCode >= 300 ? Future.error(v) : Future.value(r);
  });
}

Future<HttpClientRequest> dart_io_request(HttpClientRequest v) {
  return v.close().then((r) {
    if (r.statusCode >= 300) {
      print("failed ${v.uri.toString()} ${r.statusCode}");
    }

    return r.statusCode >= 300 ? Future.error(v) : Future.value(v);
  });
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
        return Future.value(
          request,
        ); // Returns a completed Future with the modified request
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

// convert dynamic objects to a map<String, String>
Map<String, String> params(Object? m) {
  return (jsonDecode(jsonEncode(m)) as Map<String, dynamic>).map((key, value) {
    // Convert all other types (bool, int, double, String) to their string representation
    return MapEntry(key, value.toString());
  });
}

Future<http.StreamedResponse> send(
  Uri path, {
  List<Option> options = const [],
  dynamic query = const {},
}) {
  return request(options).then((r) {
    final req = http.Request("GET", path);
    req.headers.addAll(r.headers);

    return http.Client().send(req).then(auto_error);
  });
}

Future<http.Response> get(
  Uri path, {
  List<Option> options = const [],
  dynamic query = const {},
}) {
  return request(options).then((r) {
    return http.Client().get(path, headers: r.headers).then(auto_error);
  });
}

Future<http.Response> post(Uri path, {List<Option> options = const [], Object? body}) {
  return request(options).then((r) {
    return http.Client().post(path, headers: r.headers, body: body).then(auto_error);
  });
}

Future<http.Response> delete(Uri path, {List<Option> options = const [], Object? body}) {
  return request(options).then((r) {
    return http.Client().delete(path, headers: r.headers, body: body).then(auto_error);
  });
}