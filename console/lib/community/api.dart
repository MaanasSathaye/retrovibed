import 'dart:async';
import 'dart:convert';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:retrovibed/httpx.dart' as httpx;
import './community.pb.dart';

export './community.pb.dart';

Future<CommunitySearchResponse> search({List<httpx.Option> options = const [], String query = '', int offset = 0, int limit = 100}) {
  final searchReq = CommunitySearchRequest(
    query: query, 
    offset: fixnum.Int64(offset), 
    limit: fixnum.Int64(limit)
  );
  return httpx
      .post(Uri.https(httpx.localhost(), "/c/search"), options: options, body: jsonEncode(searchReq.toProto3Json()))
      .then((v) {
        return CommunitySearchResponse.create()
          ..mergeFromProto3Json(jsonDecode(v.body));
      });
}

Future<CommunityCreateResponse> create(String domain, String description, String mimetype, {List<httpx.Option> options = const []}) {
  final community = Community(domain: domain, description: description, mimetype: mimetype);
  final createReq = CommunityCreateRequest(community: community);
  return httpx
      .post(Uri.https(httpx.localhost(), "/c/"), options: options, body: jsonEncode(createReq.toProto3Json()))
      .then((v) {
        return CommunityCreateResponse.create()
          ..mergeFromProto3Json(jsonDecode(v.body));
      });
}

Future<Community> find(String id, {List<httpx.Option> options = const []}) {
  return httpx
      .get(Uri.https(httpx.localhost(), "/c/$id"), options: options)
      .then((v) {
        final response = CommunityFindResponse.create()
          ..mergeFromProto3Json(jsonDecode(v.body));
        return response.community;
      });
}