import 'package:flutter/material.dart';
import 'package:console/designkit.dart' as ds;
import 'downloading.list.dart';
import 'available.list.dart';

class Display extends StatelessWidget {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);

    return Container(
      padding: defaults.padding,
      child: ds.RefreshBoundary(
        ListView(
          children: [
            DownloadingListDisplay(),
            AvailableListDisplay(searchController: controller),
          ],
        ),
      ),
    );
  }
}