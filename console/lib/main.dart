import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart'; // Provides [Player], [Media], [Playlist] etc.
import 'package:retrovibed/env.dart' as env;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/downloads.dart' as downloads;
import 'package:retrovibed/settings.dart' as settings;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/library.dart' as medialib;
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/meta.dart' as meta;
import 'package:retrovibed/retrovibed.dart' as retro;
import 'package:retrovibed/design.kit/theme.defaults.dart' as theming;
import 'package:retrovibed/design.kit/modals.dart' as modals;

TextScaler autoscaling(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  print("autoscaling width ${width}");
  if (width > 1920) {
    return TextScaler.linear(
      2.0,
    ).clamp(minScaleFactor: 0.8, maxScaleFactor: 4.0);
  } else {
    return TextScaler.linear(1.0);
  }
}

void main() {
  print("debug mode ${foundation.kDebugMode}");
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  final ips = retro.ips();
  retro.daemon();

  runApp(MyApp(ips));
}

class MyApp extends StatelessWidget {
  final List<String> ips;
  MyApp(this.ips, {super.key});

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: autoscaling(context)),
      child: MaterialApp(
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          cardTheme: CardThemeData(margin: EdgeInsets.all(10.0)),
          extensions: [theming.Defaults.defaults],
        ),
        themeMode: ThemeMode.dark,
        home: Material(
          child: ds.Full(
            meta.EndpointAuto(
              authn.Authenticated(
                authn.AuthzCache(
                  media.Playlist(
                    DefaultTabController(
                      length: 3,
                      child: Scaffold(
                        appBar: TabBar(
                          tabs: [
                            Tab(icon: Icon(Icons.movie)),
                            Tab(icon: Icon(Icons.download)),
                            Tab(icon: Icon(Icons.settings)),
                          ],
                        ),
                        body: ds.ErrorBoundary(
                            TabBarView(
                              children: [
                                modals.Node(media.Playlist.wrap((ctx, s) {
                                  return media.VideoScreen(
                                    env.Boolean(
                                          env.vars.AutoIdentifyMedia,
                                          fallback: true,
                                        )
                                        ? medialib.AvailableGridDisplay(
                                          focus: s.searchfocus,
                                          controller: s.controller,
                                        )
                                        : medialib.AvailableListDisplay(
                                          focus: s.searchfocus,
                                          controller: s.controller,
                                        ),
                                    s.player,
                                  );
                                })),
                                modals.Node(downloads.Display()),
                                modals.Node(settings.Display()),
                              ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              defaultips: ips,
            ),
          ),
        ),
      ),
    );
  }
}
