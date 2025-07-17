import 'dart:io';
import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'package:retrovibed/mimex.dart' as mimex;
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_selector/file_selector.dart';

class FilesEvent {
  final List<DropItemFile> files;
  const FilesEvent({required this.files});
}

class FileDropWell extends StatefulWidget {
  final Widget child;
  final Widget? loading;
  final Function()? onTap;
  final EdgeInsets? margin;
  final Future<Widget?> Function(FilesEvent i) onDropped;
  final List<String> mimetypes;
  final List<String> extensions;

  const FileDropWell(
    this.onDropped, {
    super.key,
    this.child = const Center(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.filter_rounded),
          SelectableText("Drop Files to add them to your library."),
        ],
      ),
    ),
    this.mimetypes = const [],
    this.extensions = const [],
    this.onTap,
    this.loading,
    this.margin,
  });

  factory FileDropWell.icon(
    Future<Widget?> Function(FilesEvent i) onDropped, {
    Key? key,
    List<String> mimetypes = const [],
    List<String> extensions = const [],
    Function()? onTap,
  }) {
    return FileDropWell(
      onDropped,
      key: key,
      onTap: onTap,
      child: Icon(Icons.file_upload_outlined, size: 24.0),
      loading: ds.Loading.Sized(width: 24.0, height: 24.0),
      mimetypes: mimetypes,
      extensions: extensions,
    );
  }

  @override
  _FileDropWell createState() => _FileDropWell();
}

class _FileDropWell extends State<FileDropWell> {
  bool _dragging = false;
  bool _loading = false;

  @override
  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropTarget(
      onDragDone: (evt) {
        setState(() {
          _loading = true;
        });
        Future.wait(
              evt.files.map((c) {
                return c
                    .openRead(0, mimex.defaultMagicNumbersMaxLength)
                    .first
                    .then((v) => v.toList())
                    .then((bits) {
                      return new DropItemFile(
                        c.path,
                        name: c.name,
                        mimeType:
                            mimex.fromFile(c.name, magicbits: bits).toString(),
                      );
                    });
              }),
            )
            .then((files) {
              final resolved = FilesEvent(files: files);
              widget.onDropped(resolved).whenComplete(() {
                setState(() {
                  _loading = false;
                });
              });
            })
            .catchError((cause) {
              print("failed to open file dialog ${cause}");
            });
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
      },
      child: Container(
        color: _dragging ? theme.highlightColor : null,
        margin: widget.margin,
        child: IconButton(
          onPressed: () {
            final XTypeGroup filter = XTypeGroup(
              label: "Select File(s)",
              extensions: widget.extensions,
              mimeTypes: widget.mimetypes,
            );

            setState(() {
              _loading = true;
            });
            openFiles(acceptedTypeGroups: [filter])
                .then((files) {
                  final eventfiles =
                      files.map((f) {
                        return File(f.path)
                            .openSync()
                            .read(mimex.defaultMagicNumbersMaxLength)
                            .then((v) => v.toList())
                            .then((bits) {
                              return new DropItemFile(
                                f.path,
                                name: f.name,
                                mimeType:
                                    mimex
                                        .fromFile(f.name, magicbits: bits)
                                        .toString(),
                              );
                            });
                      }).toList();

                  return Future.wait(eventfiles).then((files) {
                    final resolved = FilesEvent(files: files);
                    return widget.onDropped(resolved);
                  });
                })
                .catchError((cause) {
                  return ds.Error.unknown(cause);
                })
                .whenComplete(() {
                  setState(() {
                    _loading = false;
                  });
                });
          },
          icon: ds.Loading(
            loading: _loading,
            widget.child,
            overlay: widget.loading ?? ds.Loading.Icon,
          ),
        ),
      ),
    );
  }
}
