import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/rss.dart' as rss;
import 'package:retrovibed/torrents.dart' as torrents;
import 'package:retrovibed/meta.dart' as meta;
import 'package:retrovibed/profiles.dart' as profiles;
import 'package:retrovibed/billing.dart' as billing;
import 'package:retrovibed/wireguard.dart' as wg;

class Display extends StatelessWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: ListView(
        children: [
          ds.Accordion(
            description: Text("account"),
            content: profiles.Current(),
          ),
          ds.Accordion(description: Text("RSS"), content: rss.ListSearchable()),
          ds.Accordion(
            description: Text("Devices"),
            content: meta.DaemonList(
              onTap: (d) {
                return meta.EndpointAuto.of(
                      context,
                    )?.setdaemon(d).then((_) => Future.value(d)) ??
                    Future.error(
                      Exception(
                        "invalid widget tree missing meta.EndpointAuto",
                      ),
                    );
              },
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
            description: Row(children: [Text("VPN - wireguard")]),
            content: Container(
              constraints: BoxConstraints(maxHeight: 512),
              child: wg.ListDisplay(),
            ),
          ),
          ds.Accordion(
            description: Row(
              children: [
                Text("billing"),
                Spacer(),
                Text("opt in premium features"),
              ],
            ),
            content: billing.Registered(billing.Settings()),
          ),
        ],
      ),
    );
  }
}
