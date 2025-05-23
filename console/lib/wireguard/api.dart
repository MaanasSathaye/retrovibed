import 'dart:convert';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;
import './meta.wireguard.pb.dart';

export './meta.wireguard.pb.dart';

typedef FnWireguardSearch =
    Future<WireguardSearchResponse> Function(WireguardSearchRequest req);

typedef FnUploadRequest =
    Future<WireguardUploadResponse> Function(
      http.MultipartRequest Function(http.MultipartRequest req) mkreq,
    );

abstract class wireguard {
  static WireguardSearchRequest request({int limit = 0, String query = ""}) =>
      WireguardSearchRequest(limit: fixnum.Int64(limit));
  static WireguardSearchResponse response({WireguardSearchRequest? next}) =>
      WireguardSearchResponse(next: next ?? request(limit: 100), items: []);

  static Future<WireguardSearchResponse> get(WireguardSearchRequest req) async {
    final client = http.Client();

    return client
        .get(
          Uri.https(
            httpx.host(),
            "/wireguard/",
            jsonDecode(jsonEncode(req.toProto3Json())),
          ),
          headers: {"Authorization": httpx.auto_bearer_host()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            WireguardSearchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<WireguardDeleteResponse> delete(String id) async {
    final client = http.Client();
    return client
        .delete(
          Uri.https(httpx.host(), "/wireguard/${id}"),
          headers: {"Authorization": httpx.auto_bearer_host()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            WireguardDeleteResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<http.MultipartFile> uploadable(
    String path,
    String name,
    String mimetype,
  ) {
    return httpx.uploadable(path, name, mimetype);
  }

  static Future<WireguardUploadResponse> upload(
    http.MultipartRequest Function(http.MultipartRequest req) mkreq,
  ) async {
    final client = http.Client();
    final req = mkreq(
      http.MultipartRequest("POST", Uri.https(httpx.host(), "/wireguard/")),
    );
    req.headers["Authorization"] = httpx.auto_bearer_host();

    return client.send(req).then((v) {
      return v.stream.bytesToString().then((s) {
        return Future.value(
          WireguardUploadResponse.create()..mergeFromProto3Json(jsonDecode(s)),
        );
      });
    });
  }

  // activate the specified wireguard configuration.
  static Future<WireguardTouchResponse> touch(String id) async {
    final client = http.Client();
    return client
        .put(
          Uri.https(httpx.host(), "/wireguard/${id}"),
          headers: {"Authorization": httpx.auto_bearer_host()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            WireguardTouchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<WireguardCurrentResponse> current() async {
    final client = http.Client();
    return client
        .get(
          Uri.https(httpx.host(), "/wireguard/current"),
          headers: {"Authorization": httpx.auto_bearer_host()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            WireguardCurrentResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }
}
