import 'dart:convert';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:retrovibed/media/media.known.pb.dart';
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;

export 'package:retrovibed/media/media.known.pb.dart';

typedef FnKnownSearch =
    Future<KnownSearchResponse> Function(KnownSearchRequest req);

abstract class known {
  static KnownSearchRequest request({int limit = 0, String query = ""}) =>
      KnownSearchRequest(limit: fixnum.Int64(limit));
  static KnownSearchResponse response({KnownSearchRequest? next}) =>
      KnownSearchResponse(next: next ?? request(limit: 100), items: []);

  static Future<KnownSearchResponse> search(KnownSearchRequest req) async {
    final client = http.Client();
    return client
        .get(
          Uri.https(
            httpx.host(),
            "/k/",
            jsonDecode(jsonEncode(req.toProto3Json())),
          ),
          headers: {"Authorization": httpx.auto_bearer_host()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            KnownSearchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<KnownLookupResponse> get(String id) async {
    final client = http.Client();
    return client
        .get(
          Uri.https(
            httpx.host(),
            "/k/${id}",
           {},
          ),
          headers: {"Authorization": httpx.auto_bearer_host()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            KnownLookupResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }
}