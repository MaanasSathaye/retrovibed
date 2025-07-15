import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/authn.dart' as authn;
import 'package:retrovibed/httpx.dart' as httpx;
import './api.dart' as api;
import './download.row.controls.dart';

class RefreshingDownload extends StatefulWidget {
  final api.Download current;
  final Duration interval;
  const RefreshingDownload({super.key, required this.current, this.interval = const Duration(milliseconds: 5000)});

  @override
  State<RefreshingDownload> createState() => _DownloadingState();
}

class _DownloadingState extends State<RefreshingDownload> {
  late api.Download current;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    current = widget.current;
    timer = Timer.periodic(widget.interval, (t) {
      api.discovered.get(widget.current.media.id, options: [authn.AuthzCache.bearer(context)]).then((r) {
        setState(() {
          current = r.download;
        });
      }).catchError(
        ds.Error.boundary(
              context,
              null,
              (_, {void Function()? onTap}) => ds.Error.text("download has gone missing"),
            ),
            test: httpx.ErrorsTest.err404,
      )
      .catchError((cause) {
        print("failed to retrieve updated download data ${cause}");
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DownloadRowDisplay(
        current: current,
        trailing:
            (ctx) => DownloadRowControls(
              current: current,
              onChange: (d) {
                ds.RefreshBoundary.of(ctx)?.reset();
              },
            ),
      );
  }
}

class DownloadRowDisplay extends StatelessWidget {
  final api.Download current;
  final Widget? Function(BuildContext)? trailing;
  const DownloadRowDisplay({super.key, required this.current, this.trailing});

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(width: 10.0);

    return ds.ErrorBoundary(
      Row(
        children: [
          const Icon(Icons.download),
          gap,
          Expanded(
            child: Text(
              current.media.description,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          gap,
          Text(current.peers.toString()),
          gap,
          Text("${((current.downloaded.toDouble() / current.bytes.toDouble()) * 100.0).toStringAsPrecision(5)}"),
          gap,
          Expanded(
            child: LinearProgressIndicator(
              value:
                  current.downloaded.toInt() /
                  math.max(current.bytes.toInt(), 1),
              semanticsLabel: 'Linear progress indicator',
            ),
          ),
          gap,
          trailing?.call(context) ?? const SizedBox(),
        ],
      ),
    );
  }
}
