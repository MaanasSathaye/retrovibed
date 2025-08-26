import 'package:flutter/material.dart';
import './theme.defaults.dart';
import './inputs.dart';
import './screens.dart' as screens;

class TableRow extends StatelessWidget {
  final List<Widget> children;
  final void Function()? onTap;
  const TableRow(this.children, {super.key, this.onTap = defaulttap});

  @override
  Widget build(BuildContext context) {
    final themex = Theme.of(context);
    final defaults = Defaults.of(context);
    return Container(
      padding: defaults.padding,
      child: InkWell(
        onTap: onTap,
        hoverColor: themex.hoverColor,
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(defaults.spacing / 2),
        child: Row(spacing: defaults.spacing, children: children),
      ),
    );
  }
}

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
        mainAxisSize: MainAxisSize.min,
        children: items.map(render).toList(),
      );
    };
  }

  final Widget Function(List<T> i) render;
  final List<T> children;
  final Widget empty;
  final Widget leading;
  final Widget trailing;
  final Widget overlay;
  final bool loading;
  final Widget cause;

  const Table(
    this.render, {
    super.key,
    this.leading = const SizedBox(),
    this.trailing = const SizedBox(),
    this.empty = const SizedBox(),
    this.overlay = const SizedBox(),
    this.children = const [],
    this.loading = false,
    this.cause = const SizedBox(),
  });

  @override
  Widget build(BuildContext context) {
    final content = children.length == 0 ? empty : this.render(children);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        leading,
        screens.Loading(
          screens.Overlay(content, overlay: overlay),
          loading: loading,
          cause: cause,
        ),
        trailing,
      ],
    );
  }
}
