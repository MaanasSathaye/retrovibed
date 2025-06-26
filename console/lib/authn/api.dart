import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:retrovibed/meta/meta.authn.pb.dart';

export 'package:retrovibed/meta/meta.account.pb.dart';
export 'package:retrovibed/meta/meta.authn.pb.dart';

String bearer(String token) {
  if (token.isEmpty) return "";
  return "bearer ${token}";
}

Future<Session> current(String token) async {
  return http.Client()
      .get(
        Uri.https(httpx.metaendpoint(), "/authn/current"),
        headers: {"Authorization": bearer(token)},
      )
      .then(httpx.auto_error)
      .then((v) {
        return Session.create()..mergeFromProto3Json(jsonDecode(v.body));
      });
}

Future<Session> otp(Future<String> pending) async {
  return pending.then((token) {
    return http.Client()
        .get(
          Uri.https(httpx.metaendpoint(), "/authn/otp"),
          headers: {"Authorization": bearer(token)},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Session.create()..mergeFromProto3Json(jsonDecode(v.body));
        });
  });
}

Future<Authed> ssh() async {
  return http.Client()
      .post(
        Uri.https(httpx.metaendpoint(), "/authn/ssh"),
        headers: {"Authorization": httpx.oauth2_bearer()},
      )
      .then(httpx.auto_error)
      .then((v) {
        return Authed.create()..mergeFromProto3Json(jsonDecode(v.body));
      });
}

Future<Session> signup() {
  return http.Client()
      .post(
        Uri.https(httpx.metaendpoint(), "/authn/signup"),
        headers: {"Authorization": httpx.oauth2_bearer()},
      )
      .then(httpx.auto_error)
      .then((v) {
        return Session.create()..mergeFromProto3Json(jsonDecode(v.body));
      });
}

extension sessions on Session {
  bool get isZero {
    return !profile.hasId();
  }
}
