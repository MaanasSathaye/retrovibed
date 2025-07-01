import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/mimex.dart' as mimex;

class AvailableListDisplay extends StatefulWidget {
  final media.FnMediaSearch search;
  final media.FnUploadRequest upload;
  final TextEditingController? searchController;
  final ValueNotifier<int>? events;
  const AvailableListDisplay({
    super.key,
    this.search = media.discovered.available,
    this.upload = media.discovered.upload,
    this.searchController,
    this.events,
  });

  @override
  State<StatefulWidget> createState() => _AvailableListDisplay();
}

class _AvailableListDisplay extends State<AvailableListDisplay> {
  bool _loading = true;
  ds.Error? _cause = null;
  media.MediaSearchResponse _res = media.media.response(
    next: media.media.request(limit: 32),
  );

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void refresh() {
    widget
        .search(_res.next)
        .then((v) {
          setState(() {
            _res = v;
            _loading = false;
          });
        })
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unknown(e);
            _loading = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    refresh();
    widget.events?.addListener(() {
      refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final upload = (FilesEvent v) {
      setState(() {
        _loading = true;
      });

      final multiparts = v.files.map((c) {
        return media.media.uploadable(c.path, c.name, c.mimeType!);
      });

      return Future.microtask(() {
        return Future.wait(
              multiparts.map((fv) {
                return fv.then((v) {
                  return widget
                      .upload((req) {
                        req..files.add(v);
                        return req;
                      })
                      .then((uploaded) {
                        return media.discovered
                            .download(uploaded.media.id)
                            .then((_) {
                              widget.events?.value += 1;
                            });
                      })
                      .catchError((cause) {
                        setState(() {
                          _cause = ds.Error.unknown(cause);
                        });
                      });
                });
              }),
            )
            .then((v) => ds.NullWidget)
            .catchError((cause) {
              return ds.Error.unknown(cause);
            })
            .whenComplete(() {
              setState(() {
                _loading = false;
              });
            });
      });
    };

    return ds.Table(
      loading: _loading,
      cause: _cause,
      children: _res.items,
      leading: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: TextField(
                  controller: widget.searchController,
                  decoration: InputDecoration(
                    hintText: "search available content",
                  ),
                  onChanged:
                      (v) => setState(() {
                        _res.next.query = v;
                      }),
                  onSubmitted: (v) {
                    setState(() {
                      _res.next.offset = fixnum.Int64(0);
                    });
                    refresh();
                  },
                ),
              ),
              IconButton(
                onPressed:
                    _res.next.offset > 0
                        ? () {
                          setState(() {
                            _res.next.offset -= 1;
                          });
                          refresh();
                        }
                        : null,
                icon: Icon(Icons.arrow_left),
              ),
              IconButton(
                onPressed:
                    _res.items.isNotEmpty
                        ? () {
                          setState(() {
                            _res.next.offset += 1;
                          });
                          refresh();
                        }
                        : null,
                icon: Icon(Icons.arrow_right),
              ),
              ds.buttons.refresh(onPressed: refresh),
              ds.FileDropWell(
                upload,
                child: Icon(Icons.file_upload_outlined),
                extensions: ["torrent"],
                loading: ds.Loading.Sized(width: 12.0, height: 12.0),
              ),
              ds.buttons.settings(onPressed: () { print("settings not implement for downloads availability");}),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [Spacer(), Text("description"), Spacer()],
          ),
        ],
      ),
      ds.Table.expanded<media.Media>(
        (v) => media.RowDisplay(
          media: v,
          onTap:
              () => media.discovered
                  .download(v.id)
                  .then((v) {
                    widget.events ?? refresh();
                    widget.events?.value += 1;
                  })
                  .catchError((cause) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to download: $cause")),
                    );
                    return null;
                  }),
          leading: [Icon(mimex.icon(v.mimetype))],
          trailing: [Icon(Icons.download)],
        ),
      ),
    );
  }
}
