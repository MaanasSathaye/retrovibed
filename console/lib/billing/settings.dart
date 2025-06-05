import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;
import './plan.summary.dart';
import './purchase.dart';

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  State<Settings> createState() => _Settings();
}

class _Settings extends State<Settings> {
  PlanSummary current = free();
  PlanSummary desired = free();

  void setState(VoidCallback fn) {
    if (!mounted) return;
    super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return forms.Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(
            label: Text("plan"),
            input: DropdownButton(
              alignment: Alignment.topLeft,
              isExpanded: true,
              value: current,
              items: [
                DropdownMenuItem(child: Text("free"), value: free()),
                DropdownMenuItem(child: Text("basic"), value: basic()),
                DropdownMenuItem(child: Text("premium"), value: premium()),
              ],
              onChanged: (v) {
                setState(() {
                  current = v ?? current;
                });
              },
            ),
          ),
          current,
          Purchase(current: current, desired: desired),
        ],
      ),
    );
  }
}
