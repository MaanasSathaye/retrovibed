import 'package:flutter/material.dart';
import 'package:retrovibed/meta.dart' as _meta;
import 'package:retrovibed/authz.dart' as authz;

class AuthzCache extends StatefulWidget {
  final Widget child;

  const AuthzCache(this.child, {Key? key}) : super(key: key);

  static _AuthzCache? of(BuildContext context) {
    return context.findAncestorStateOfType<_AuthzCache>();
  }

  @override
  State<AuthzCache> createState() => _AuthzCache();
}

class _AuthzCache extends State<AuthzCache> {
  authz.Cached<_meta.Token> meta = authz.Cached(
    authz.Bearer(_meta.Token(), ""),
    authz.refresh(
      (c) => _meta.authz().then((v) {
        return authz.Bearer(v.token, v.bearer);
      }).catchError((e) {
        print("failed to refresh token cache ${e}");
        return authz.Bearer(c, "");
      }),
      (c, ts) =>
          DateTime.fromMillisecondsSinceEpoch(c.expires.toInt()).isBefore(ts),
    ),
  );

  @override
  void initState() {
    super.initState();
    Future.wait([meta.token()]).whenComplete(() {});
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
