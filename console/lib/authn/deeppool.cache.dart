import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:retrovibed/meta.dart' as _meta;
import 'package:retrovibed/meta/api.deeppool.dart' as deeppool;
import 'package:retrovibed/httpx.dart' as httpx;
import 'package:retrovibed/authz.dart' as authz;
import 'authenticated.dart';
class DeeppoolAuthzCache extends StatefulWidget {
  final Widget child;

  const DeeppoolAuthzCache(this.child, {Key? key}) : super(key: key);

  static _AuthzCache? of(BuildContext context) {
    return context.findAncestorStateOfType<_AuthzCache>();
  }

  static httpx.Option bearer(BuildContext context) {
    return httpx.Request.bearer(
      of(context)!.meta.token().then((v) => v.bearer),
    );
  }

  @override
  State<DeeppoolAuthzCache> createState() => _AuthzCache();
}

class _AuthzCache extends State<DeeppoolAuthzCache> {
  authz.Cached<_meta.Token> meta = authz.Cached(
    authz.Bearer(_meta.Token(), ""),
    authz.Cached.noprefresh,
  );

  void refresh() {
    meta = authz.Cached(
      authz.Bearer(_meta.Token(), ""),
      authz.refresh(
        (c) => deeppool
            .authz(options: [Authenticated.bearer(context)])
            .then((v) {
              print("DERP DERP ${jsonDecode(jsonEncode(v.toProto3Json()))}");
              return authz.Bearer(v.token, v.bearer);
            })
            .catchError((e) {
              print("failed to refresh token cache ${e}");
              return authz.Bearer(c, "");
            }),
        (c, ts) {
          return DateTime.fromMillisecondsSinceEpoch(
            c.expires.toInt() * 1000,
            isUtc: true,
          ).isBefore(ts);
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    refresh();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
