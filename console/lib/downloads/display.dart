import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'downloading.list.dart';
import 'available.list.dart';

class Display extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);

    return Container(
      padding: defaults.padding,
      child: ListView(
        children: [
          ds.RefreshBoundary(DownloadingListDisplay()),
          AvailableListDisplay(searchController: controller),
        ],
      ),
    );
  }
}
