import 'dart:convert';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:retrovibed/media/media.pb.dart';
import 'package:http/http.dart' as http;
import 'package:retrovibed/httpx.dart' as httpx;

export 'package:retrovibed/media/media.pb.dart';

typedef FnMediaSearch =
    Future<MediaSearchResponse> Function(MediaSearchRequest req, {List<httpx.Option> options});

typedef FnDownloadSearch =
    Future<DownloadSearchResponse> Function(DownloadSearchRequest req, {List<httpx.Option> options});

typedef FnUploadRequest =
    Future<MediaUploadResponse> Function(
      http.MultipartRequest Function(http.MultipartRequest req) mkreq,
    );

Future<MediaSearchResponse> recent() async {
  final client = http.Client();
  return client
      .get(
        Uri.https(httpx.host(), "/m/recent"),
        headers: {"Authorization": httpx.auto_bearer_host()},
      )
      .then((v) {
        return Future.value(
          MediaSearchResponse.create()..mergeFromProto3Json(jsonDecode(v.body)),
        );
      });
}

abstract class media {
  static MediaSearchRequest request({int limit = 0, String query = ""}) =>
      MediaSearchRequest(limit: fixnum.Int64(limit));
  static MediaSearchResponse response({MediaSearchRequest? next}) =>
      MediaSearchResponse(next: next ?? request(limit: 100), items: []);

  static Future<MediaSearchResponse> get(
    MediaSearchRequest req,
    {List<httpx.Option> options = const []}
  ) async {
    return httpx
        .get(
          Uri.https(
            httpx.host(),
            "/m/",
            jsonDecode(jsonEncode(req.toProto3Json())),
          ),
          options: options,
        )
        .then((v) {
          return Future.value(
            MediaSearchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static String download_uri(String id) {
    return Uri.https(httpx.host(), "/m/${id}").toString();
  }

  static Future<MediaDeleteResponse> delete(String id) async {
    final client = http.Client();
    return client
        .delete(
          Uri.https(httpx.host(), "/m/${id}"),
          headers: {"Authorization": httpx.auto_bearer_host()},
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            MediaDeleteResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<MediaUpdateResponse> update(String id, Media upd) async {
    final client = http.Client();
    return client
        .post(
          Uri.https(httpx.host(), "/m/${id}"),
          headers: {"Authorization": httpx.auto_bearer_host()},
          body: jsonEncode(MediaUpdateRequest(media: upd).toProto3Json()),
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            MediaUpdateResponse.create()
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

  static Future<MediaUploadResponse> upload(
    http.MultipartRequest Function(http.MultipartRequest req) mkreq,
  ) async {
    final client = http.Client();
    final req = mkreq(
      http.MultipartRequest("POST", Uri.https(httpx.host(), "/m/")),
    );
    req.headers["Authorization"] = httpx.auto_bearer_host();

    return client.send(req).then((v) {
      return v.stream.bytesToString().then((s) {
        return Future.value(
          MediaUploadResponse.create()..mergeFromProto3Json(jsonDecode(s)),
        );
      });
    });
  }
}

abstract class discoveredsearch {
  static DownloadSearchRequest request({int limit = 0}) =>
      DownloadSearchRequest(limit: fixnum.Int64(limit));
  static DownloadSearchResponse response({DownloadSearchRequest? next}) =>
      DownloadSearchResponse(next: next ?? request(limit: 100), items: []);
}

abstract class discovered {
  static Future<DownloadSearchResponse> available(
    DownloadSearchRequest req,
    {List<httpx.Option> options = const []}
  ) async {
    return httpx.get(
          Uri.https(
            httpx.host(),
            "/d/available",
            httpx.params(req.toProto3Json()),
          ),
          options: options,
        )
        .then((v) {
          return Future.value(
            DownloadSearchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<DownloadSearchResponse> downloading(
    DownloadSearchRequest req,
    {List<httpx.Option> options = const []}
  ) async {
      return httpx
      .get(Uri.https(httpx.host(), "/d/downloading"), options: options)
      .then((v) {
          return Future.value(
            DownloadSearchResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<MagnetCreateResponse> magnet(
    MagnetCreateRequest req,
    {List<httpx.Option> options = const []}
  ) async {
      return httpx
      .post(Uri.https(httpx.host(), "/d/magnet"), body: jsonEncode(req.toProto3Json()), options: options)
      .then((v) {
          return Future.value(
            MagnetCreateResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }

  static Future<MediaUploadResponse> upload(
    http.MultipartRequest Function(http.MultipartRequest req) mkreq,
  ) async {
    final client = http.Client();
    final req = mkreq(
      http.MultipartRequest("POST", Uri.https(httpx.host(), "/d/")),
    );
    req.headers["Authorization"] = httpx.auto_bearer_host();

    return client.send(req).then((v) {
      return v.stream.bytesToString().then((s) {
        return Future.value(
          MediaUploadResponse.create()..mergeFromProto3Json(jsonDecode(s)),
        );
      });
    });
  }

  static Future<DownloadBeginResponse> download(String id) async {
    final client = http.Client();
    return client
        .post(
          Uri.https(httpx.host(), "/d/${id}", null),
          headers: {"Authorization": httpx.auto_bearer_host()},
          body: jsonEncode({}),
        )
        .then(httpx.auto_error)
        .then((v) {
          return DownloadBeginResponse.create()
            ..mergeFromProto3Json(jsonDecode(v.body));
        });
  }

  static Future<DownloadMetadataResponse> get(
    String id,
    {List<httpx.Option> options = const []}
  ) async {
    return httpx.get(
          Uri.https(httpx.host(), "/d/${id}", null),
          options: options,
        )
        .then(httpx.auto_error)
        .then((v) {
          return DownloadMetadataResponse.create()
            ..mergeFromProto3Json(jsonDecode(v.body));
        });
  }

  static Future<DownloadPauseResponse> pause(String id) async {
    final client = http.Client();
    return client
        .delete(
          Uri.https(httpx.host(), "/d/${id}", null),
          headers: {"Authorization": httpx.auto_bearer_host()},
          body: jsonEncode({}),
        )
        .then(httpx.auto_error)
        .then((v) {
          return Future.value(
            DownloadPauseResponse.create()
              ..mergeFromProto3Json(jsonDecode(v.body)),
          );
        });
  }
}
