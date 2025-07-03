import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;

class Table<T> extends StatelessWidget {
  static Widget Function(List<T> i) expanded<T>(Widget Function(T i) render) {
    return (List<T> items) {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: items.map(render).toList(),
        ),
      );
    };
  }

  static Widget Function(List<T> i) inline<T>(Widget Function(T i) render) {
    return (List<T> items) {
      return Column(
        mainAxisSize: MainAxisSize.max,
        children: items.map(render).toList(),
      );
    };
  }

  final Widget Function(List<T> i) render;
  final List<T> children;
  final Widget empty;
  final Widget leading;
  final Widget trailing;
  final Widget? overlay;
  final bool loading;
  final ds.Error? cause;
  final int flex;

  const Table(
    this.render, {
    super.key,
    this.leading = const SizedBox(),
    this.trailing = const SizedBox(),
    this.empty = const SizedBox(),
    this.overlay = null,
    this.children = const [],
    this.loading = false,
    this.cause = null,
    this.flex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final content = children.length == 0 ? empty : this.render(children);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        ds.Overlay(
          child: ds.Loading(loading: loading, cause: cause, content),
          overlay: overlay,
        ),
        trailing,
      ],
    );
  }
}
