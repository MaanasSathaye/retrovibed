import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/rss.dart' as rss;
import 'package:retrovibed/torrents.dart' as torrents;
import 'package:retrovibed/meta.dart' as meta;
import 'package:retrovibed/profiles.dart' as profiles;
import 'package:retrovibed/billing.dart' as billing;
import 'package:retrovibed/wireguard.dart' as wg;
import 'package:retrovibed/storage.dart' as storage;

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
            description: Text("Libraries"),
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
            description: Row(
              children: [
                Text("VPN - wireguard"),
                // requires we implement the protocol negotiation feature.
                // Spacer(),
                // Text("make your library reachable from anywhere"),
              ],
            ),
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
          ds.Accordion(
            disabled: Text(
              "manage local and archive storage usage - currently in private alpha",
            ),
            description: Text("storage"),
            content: storage.Settings(),
          ),
          ds.Accordion(
            disabled: Text(
              "manage torrent settings - currently in private alpha",
            ),
            description: Row(children: [Text("torrents")]),
            content: Column(children: [torrents.SettingsLeech()]),
          ),
          ds.Accordion(
            disabled: Text(
              "manage permissions and access controls - currently in private alpha",
            ),
            description: Row(children: [Text("user management")]),
            content: Column(children: [torrents.SettingsLeech()]),
          ),
        ],
      ),
    );
  }
}
