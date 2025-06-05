import 'dart:async';
import 'dart:convert';
import 'package:qs_dart/qs_dart.dart' as qs;
import 'package:retrovibed/httpx.dart' as httpx;
import './meta.billing.pb.dart';

export './meta.billing.pb.dart';

Future<BillingLookupResponse> lookup({List<httpx.Option> options = const []}) {
  return httpx
      .get(Uri.https(httpx.metaendpoint(), "/m/b/"), options: options)
      .then((v) {
        return BillingLookupResponse.create()
          ..mergeFromProto3Json(jsonDecode(v.body));
      });
}

Future<BillingCreateResponse> create({List<httpx.Option> options = const []}) {
  return httpx
      .post(Uri.https(httpx.metaendpoint(), "/m/b/new"), options: options)
      .then((v) {
        return BillingCreateResponse.create()
          ..mergeFromProto3Json(jsonDecode(v.body));
      });
}

Future<BillingSessionResponse> session(String plan, {List<httpx.Option> options = const []}) {
    return httpx
      .get(Uri.https(httpx.metaendpoint(), "/m/b/session", qs.decode(qs.encode(BillingSessionRequest(plan: plan).toProto3Json()))), options: options)
      .then((v) {
        return BillingSessionResponse.create()
          ..mergeFromProto3Json(jsonDecode(v.body));
      });
}

Future<BillingSubscribeResponse> subscribe(String plan) {
  return httpx.get(
        Uri.https(
          httpx.metaendpoint(),
          "/m/b/subscribe",
          qs.decode(qs.encode(BillingSubscribeRequest(plan: plan).toProto3Json())),
        ),
      )
      .then((v) {
        return BillingSubscribeResponse.create()
          ..mergeFromProto3Json(jsonDecode(v.body));
      });
}
