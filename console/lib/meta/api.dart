import 'dart:convert';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:http/http.dart' as http;
import 'package:console/httpx.dart' as httpx;
import './meta.daemon.pb.dart';
import './meta.authz.pb.dart';

export './meta.daemon.pb.dart';
export './meta.authz.pb.dart';

Future<http.Response> healthz({String? host}) async {
  return http.Client()
      .get(Uri.https(host ?? httpx.host(), "/healthz"))
      .then(httpx.auto_error);
}

Future<AuthzResponse> authz({String? host}) {
  final _host = host ?? httpx.host();
  return http.Client()
      .get(
        Uri.https(_host, "/meta/authz/"),
        headers: {"Authorization": httpx.auto_bearer_host(host: _host)},
      )
      .then(httpx.auto_error)
      .then((v) {
        return AuthzResponse.create()..mergeFromProto3Json(jsonDecode(v.body));
      });
}

abstract class daemons {
  static DaemonSearchRequest request({int limit = 0}) =>
      DaemonSearchRequest(limit: fixnum.Int64(limit));
  static DaemonSearchResponse response({DaemonSearchRequest? next}) =>
      DaemonSearchResponse(next: next ?? request(limit: 128), items: []);

  static Future<DaemonSearchResponse> search(DaemonSearchRequest req) async {
    return http.Client()
        .get(
          Uri.https(
            httpx.localhost(),
            "/meta/d/",
            jsonDecode(jsonEncode(req.toProto3Json())),
          ),
          headers: {"Authorization": httpx.auto_bearer()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return DaemonSearchResponse.create()
            ..mergeFromProto3Json(jsonDecode(v.body));
        });
  }

  static Future<DaemonCreateResponse> create(DaemonCreateRequest req) async {
    return http.Client()
        .post(
          Uri.https(httpx.localhost(), "/meta/d/"),
          headers: {"Authorization": httpx.auto_bearer()},
          body: jsonEncode(req.toProto3Json()),
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            DaemonCreateResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<DaemonDisableResponse> delete(String id) async {
    return http.Client()
        .delete(
          Uri.https(httpx.localhost(), "/meta/d/${id}"),
          headers: {"Authorization": httpx.auto_bearer()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            DaemonDisableResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<DaemonLookupResponse> latest() async {
    return http.Client()
        .get(
          Uri.https(httpx.localhost(), "/meta/d/latest"),
          headers: {"Authorization": httpx.auto_bearer()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            DaemonLookupResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }
}
