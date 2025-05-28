import 'package:retrovibed/design.kit/file.drop.well.dart';
import 'package:fixnum/fixnum.dart' as fixnum;
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/media.dart' as media;
import 'package:retrovibed/httpx.dart' as httpx;

class AvailableGridDisplay extends StatefulWidget {
  final media.FnMediaSearch search;
  final media.FnUploadRequest upload;
  final TextEditingController? controller;
  final FocusNode? focus;
  const AvailableGridDisplay({
    super.key,
    this.search = media.media.get,
    this.upload = media.media.upload,
    this.controller,
    this.focus,
  });

  @override
  State<StatefulWidget> createState() => _AvailableGridDisplay();
}

class _AvailableGridDisplay extends State<AvailableGridDisplay> {
  bool _loading = true;
  ds.Error? _cause = null;
  media.MediaSearchResponse _res = media.media.response(
    next: media.media.request(limit: 32),
  );

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  void reseterr() {
    setState(() {
      _cause = null;
    });
  }

  void refresh(media.MediaSearchRequest req) {
    widget
        .search(req)
        .then((v) {
          setState(() {
            _res = v;
            _loading = false;
          });

          widget.focus?.requestFocus();
          ds.SearchTray.refocus(widget.controller);
        })
        .catchError((cause) {
          setState(() {
            _cause = ds.Error.unauthorized(cause, onTap: reseterr);
            _loading = false;
          });
        }, test: httpx.ErrorsTest.unauthorized)
        .catchError((e) {
          setState(() {
            _cause = ds.Error.unknown(e, onTap: reseterr);
            _loading = false;
          });
        });
  }

  @override
  void initState() {
    super.initState();
    _res.next..query = widget.controller?.text ?? "";
    refresh(_res.next);
  }

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);
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
                        setState(() {
                          _res.items.add(uploaded.media);
                        });
                      })
                      .catchError((cause) {
                        setState(() {
                          _cause = ds.Error.unknown(cause, onTap: reseterr);
                        });
                      });
                });
              }),
            )
            .then((v) => ds.NullWidget)
            .catchError((cause) {
              return ds.Error.unknown(cause, onTap: reseterr);
            })
            .whenComplete(
              () => setState(() {
                _loading = false;
              }),
            );
      });
    };

    return ds.Loading(
      cause: _cause,
      loading: _loading,
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ds.SearchTray(
              inputDecoration: InputDecoration(hintText: "search the library"),
              controller: widget.controller,
              focus: widget.focus,
              onSubmitted: (v) {
                setState(() {
                  _res.next.query = v;
                  _res.next.offset = fixnum.Int64(0);
                });
                refresh(_res.next);
              },
              next: (i) {
                setState(() {
                  _res.next.offset = i;
                });
                refresh(_res.next);
              },
              current: _res.next.offset,
              empty: fixnum.Int64(_res.items.length) < _res.next.limit,
              trailing: ds.FileDropWell(
                upload,
                child: IgnorePointer(child: Icon(Icons.file_upload_outlined)),
              ),
              autofocus: true,
            ),
            Expanded(
              child: GridView.builder(
                padding: defaults.padding,
                itemCount: _res.items.length, // Number of items in your grid
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 633, // Maximum width of each item
                  crossAxisSpacing:
                      defaults.padding?.horizontal ??
                      0.0, // Spacing between columns
                  mainAxisSpacing:
                      defaults.padding?.vertical ?? 0.0, // Spacing between rows
                  childAspectRatio:
                      16 / 9, // Aspect ratio of each grid item (width/height)
                ),
                itemBuilder: (context, index) {
                  final _media = _res.items.elementAt(index);
                  return ds.Card(
                      onDoubleTap: media.PlayAction(context, _media, _res),
                      leading: Center(
                        child: Text(
                          _media.description,
                          overflow: TextOverflow.fade,
                          maxLines: 1,
                        ),
                      ),
                      image: AspectRatio(
                        aspectRatio: 27 / 40,
                        child: Opacity(
                          opacity: 0.25,
                          child: SizedBox.expand(
                            child: Icon(
                              Icons.image_outlined,
                              // color: Colors.grey,
                              size: 128,
                              // size: double.maxFinite,
                            ),
                          ),
                        ),
                      ),
                      child: Text("Magna nulla aute ea sunt esse dolore Lorem excepteur fugiat esse culpa officia. Incididunt proident reprehenderit ut anim dolore non mollit commodo nostrud proident. Sit est consequat consequat sit nisi commodo. Tempor quis amet dolore ut voluptate ullamco. Tempor consectetur velit minim in excepteur aliquip ipsum. Magna cillum ad laboris do duis proident culpa dolor ad labore ut. Elit aliquip aute nulla eu id anim ullamco."),
                      trailing: Row(children: [Flexible(flex: 4, child: Center(child: ds.Rating(rating: 0.6))), Spacer(flex: 9)]),
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
