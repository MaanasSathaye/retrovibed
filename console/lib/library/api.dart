import 'dart:convert';
import 'dart:typed_data';
import 'package:lru/lru.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:retrovibed/media/media.known.pb.dart';
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:retrovibed/design.kit/bytesx.dart';

export 'package:retrovibed/media/media.known.pb.dart';

typedef FnKnownSearch =
    Future<KnownSearchResponse> Function(KnownSearchRequest req);

abstract class known {
  static LruTypedDataCache<String, Uint8List> cache =
      LruTypedDataCache<String, Uint8List>(
        capacity: 256,
        capacityInBytes: bytesx.MiB,
      );
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

  static Future<KnownLookupResponse> cached(
    String id,
    Future<KnownLookupResponse> Function() fetch,
  ) {
    final c = cache[id];
    return c == null
        ? fetch().then((v) {
          cache[id] = v.known.writeToBuffer();
          return v;
        })
        : Future.value(KnownLookupResponse(known: Known.fromBuffer(c)));
  }

  static Future<KnownLookupResponse> get(
    String id, {
    List<httpx.Option> options = const [],
  }) async {
    return httpx
        .get(Uri.https(httpx.host(), "/k/${id}", {}), options: options)
        .then((v) {
          return Future.value(
            KnownLookupResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }
}

T cached<T>(T? v, T fallback) => v ?? fallback;
