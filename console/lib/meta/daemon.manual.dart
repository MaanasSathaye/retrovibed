import 'package:flutter/material.dart';
import 'package:console/design.kit/forms.dart' as forms;
import 'package:console/httpx.dart' as httpx;
import './api.dart' as api;

class ManualConfiguration extends StatefulWidget {
  final void Function()? retry;
  final void Function(api.Daemon) connect;

  ManualConfiguration({super.key, this.retry, required this.connect});

  @override
  State<ManualConfiguration> createState() => _ManualConfigurationView();
}

class _ManualConfigurationView extends State<ManualConfiguration> {
  final String defaultLocalhost = httpx.localhost();
  String _hostname = '';

  @override
  Widget build(BuildContext context) {
    return forms.Container(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            forms.Field(
              label: SelectableText("hostname"),
              input: TextFormField(
                autofocus: true,
                decoration: new InputDecoration(
                  hintText: defaultLocalhost,
                  helperText: "hostname and port for the retrovibed instance",
                ),
                keyboardType: TextInputType.number,
                onChanged: (v) {
                  setState(() {
                    _hostname = v;
                  });
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.retry != null)
                  TextButton(child: Text("retry"), onPressed: widget.retry),
                TextButton(
                  child: Text("connect"),
                  onPressed: () {
                    api.daemons
                        .create(
                          api.DaemonCreateRequest(
                            daemon: api.Daemon(hostname: _hostname.isEmpty ? defaultLocalhost : _hostname),
                          ),
                        ).then((d) {
                          return widget.connect(d.daemon);
                        }).catchError((cause) {
                          print("failed ${cause}");
                        });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
