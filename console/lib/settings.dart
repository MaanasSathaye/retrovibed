import 'package:flutter/material.dart';
import 'package:console/designkit.dart' as ds;
import 'package:console/rss.dart' as rss;
import 'package:console/torrents.dart' as torrents;
import 'package:console/meta.dart' as meta;

class Display extends StatelessWidget {
  const Display({super.key});

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);

    return ListView(
      children: [
        ds.Accordion(
          description: Text("RSS"),
          content: Container(
            padding: defaults.padding,
            child: rss.ListSearchable(),
          ),
        ),
        ds.Accordion(
          description: Text("Servers"),
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
          disabled: Text("coming soon"),
          description: Row(children: [Text("VPN (wireguard)")]),
          content: Container(),
        ),
        ds.Accordion(
          disabled: Text("coming soon - opt in premium features"),
          description: Text("billing"),
          content: Container(),
        ),
      ],
    );
  }
}
