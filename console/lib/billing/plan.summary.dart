import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;

PlanSummary free() => const PlanSummary(
  id: "prod_SWPUSEgaKJygkf",
  key: ValueKey("free"),
  storage: Text("none"),
  bandwidth: Text("none"),
  price: Text("\$0/month"),
  mobile: Text("no"),
);

PlanSummary basic() => const PlanSummary(
  id: "prod_SWPVKrSbqVuFDC",
  key: ValueKey("personal"),
  storage: Text("2TB included + \$0.20 each additional 128 GB"),
  bandwidth: Text("128 GB / month"),
  price: Text("\$4/month"),
  mobile: Text("no"),
);

PlanSummary premium() => const PlanSummary(
  id: "prod_SWPZljG0jYjrdl",
  key: ValueKey("premium"),
  storage: Text("4TB included + \$0.17 each additional 128 GB"),
  bandwidth: Text("no hard limits, but abuse will result in rate limits"),
  price: Text("\$12/month"),
  mobile: Text("yes"),
);

class PlanSummary extends StatelessWidget {
  final String id;
  final Widget storage;
  final Widget bandwidth;
  final Widget price;
  final Widget mobile;

  const PlanSummary({
    super.key,
    required this.id,
    required this.storage,
    required this.price,
    required this.mobile,
    required this.bandwidth,
  });

  @override
  Widget build(BuildContext context) {
    return forms.Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(label: Text("Price"), input: price),
          forms.Field(label: Text("storage"), input: storage),
          forms.Field(label: Text("bandwidth"), input: bandwidth),
          forms.Field(label: Text("mobile support"), input: mobile),
        ],
      ),
    );
  }
}
