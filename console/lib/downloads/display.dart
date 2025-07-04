import 'package:flutter/material.dart';
import 'package:retrovibed/designkit.dart' as ds;
import 'downloading.list.dart';
import 'available.list.dart';

class Display extends StatefulWidget {
  const Display({super.key});

  @override
  State<Display> createState() => _DisplayState();
}

class _DisplayState extends State<Display> {
  late final TextEditingController controller = TextEditingController();
  late final ValueNotifier<int> refresh = ValueNotifier(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    refresh.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaults = ds.Defaults.of(context);

    return Container(
      padding: defaults.padding,
      child: ListView(
        children: [
          DownloadingListDisplay(events: refresh),
          AvailableListDisplay(controller: controller, events: refresh),
        ],
      ),
    );
  }
}

