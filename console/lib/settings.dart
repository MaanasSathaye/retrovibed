import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/rss.dart' as rss;
import 'package:retrovibed/torrents.dart' as torrents;
import 'package:retrovibed/meta.dart' as meta;
import 'package:retrovibed/profiles.dart' as profiles;
import 'package:retrovibed/wireguard.dart' as wg;

class Display extends StatelessWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);

    return SelectionArea(
      child: ListView(
        children: [
          ds.Accordion(
            disabled: Text("coming soon"),
            description: Text("you"),
            content: Container(
              padding: defaults.padding,
              child: profiles.Current(),
            ),
          ),
          ds.Accordion(
            description: Text("RSS"),
            content: Container(
              padding: defaults.padding,
              child: rss.ListSearchable(),
            ),
          ),
          ds.Accordion(
            description: Text("Devices"),
            content: Container(
              padding: defaults.padding,
              child: meta.DaemonList(
                onTap: (d) {
                  meta.EndpointAuto.of(context)?.setdaemon(d);
                },
              ),
            ),
          ),
          ds.Accordion(
            disabled: Text("coming soon"),
            description: Text("storage"),
            content: Container(),
          ),
          ds.Accordion(
            disabled: Text("coming soon"),
            description: Row(children: [Text("torrents")]),
            content: Column(children: [torrents.SettingsLeech()]),
          ),
          ds.Accordion(
            description: Row(children: [Text("VPN - wireguard")
          ]),
            content: Container(
              constraints: BoxConstraints(maxHeight: 512),
              child: wg.ListDisplay(),
            ),
          ),
          ds.Accordion(
            disabled: Text("coming soon - opt in premium features"),
            description: Text("billing"),
            content: Container(),
          ),
        ],
      ),
    );
  }
}
