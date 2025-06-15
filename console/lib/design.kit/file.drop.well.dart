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
  final Function()? onTap;
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
  });

  @override
  _FileDropWell createState() => _FileDropWell();
}

class _FileDropWell extends State<FileDropWell> {
  bool _dragging = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loading = (bool b) {
      if (!mounted) {
        return;
      }

      setState(() {
        _loading = b;
      });
    };

    return DropTarget(
      onDragDone: (evt) {
        loading(true);
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
                loading(false);
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
        child: TextButton(
          onPressed: () {
            final XTypeGroup filter = XTypeGroup(
              label: "Select File(s)",
              extensions: widget.extensions,
              mimeTypes: widget.mimetypes,
            );

            loading(true);
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
                    return widget.onDropped(resolved).whenComplete(() {
                      loading(false);
                    });
                  });
                })
                .catchError((cause) {
                  print("failed to open files ${cause}");
                  return ds.Error.unknown(cause);
                })
                .whenComplete(() {
                  loading(false);
                });
          },
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [ds.Loading(loading: _loading, child: widget.child)],
          ),
        ),
      ),
    );
  }
}
