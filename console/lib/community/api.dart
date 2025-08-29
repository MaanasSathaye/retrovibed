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
    final rawParams = jsonDecode(jsonEncode(req.toProto3Json()));
    final params = (rawParams as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v.toString()))
        ..removeWhere((key, value) => value.isEmpty);
    print("DEBUG: Community API params before Uri: $params");
    final uri = Uri.https(httpx.metaendpoint(), "/c", params);
    print("DEBUG: Community API final URI: $uri");
    return httpx
        .get(
          uri,
          options: options,
        )
        .then((v) {
          print("DEBUG: Community API Success Response - Status: ${v.statusCode}, Body: ${v.body}");
          return Future.value(
            CommunitySearchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        })
        .catchError((error) {
          print("DEBUG: Community API Error caught: $error");
          if (error is http.Response) {
            print("DEBUG: Error response - Status: ${error.statusCode}, Body: ${error.body}");
          }
          throw error;
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