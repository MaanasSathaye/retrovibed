import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;
import './community.pb.dart';

export './community.pb.dart';

class CommunityAPI {
  static Future<CommunitySearchResponse> search(
    CommunitySearchRequest req, {
    List<httpx.Option> options = const [],
  }) async {
    return httpx
        .get(
          Uri.https(
            httpx.metaendpoint(),
            "/c/",
            jsonDecode(jsonEncode(req.toProto3Json())),
          ),
          options: options,
        )
        .then((v) {
          return Future.value(
            CommunitySearchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<CommunityCreateResponse> create(
    CommunityCreateRequest req, {
    List<httpx.Option> options = const [],
  }) async {
    return httpx
        .post(
          Uri.https(
            httpx.metaendpoint(),
            "/c/",
          ),
          options: options,
          body: jsonEncode(req.toProto3Json()),
        )
        .then((v) {
          return Future.value(
            CommunityCreateResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<CommunityFindResponse> find(
    String id, {
    List<httpx.Option> options = const [],
  }) async {
    return httpx
        .get(
          Uri.https(
            httpx.metaendpoint(),
            "/c/$id",
          ),
          options: options,
        )
        .then((v) {
          return Future.value(
            CommunityFindResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }
}