import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;

PlanSummary free() => const PlanSummary(
  key: ValueKey("free"),
  storage: Text("none"),
  price: Text("\$0/month"),
  featureMobile: Text("no"),
  // featureMobile: FittedBox(
  //   alignment: Alignment.centerLeft,
  //   fit: BoxFit.contain,
  //   child: IconCheckmark(false),
  // ),
);
PlanSummary basic() => const PlanSummary(
  key: ValueKey("basic"),
  storage: Text("2TB included + \$0.13 each additional 100 GB"),
  price: Text("\$3/month"),
  featureMobile: Text("no"),
  // featureMobile: FittedBox(
  //   alignment: Alignment.centerLeft,
  //   fit: BoxFit.contain,
  //   child: IconCheckmark(false),
  // ),
);
PlanSummary premium() => const PlanSummary(
  key: ValueKey("premium"),
  storage: Text("2TB included + \$0.13 each additional 100 GB"),
  price: Text("\$10/month"),
  featureMobile: Text("yes"),
  // featureMobile: FittedBox(
  //   alignment: Alignment.centerLeft,
  //   fit: BoxFit.contain,
  //   child: IconCheckmark(true),
  // ),
);

class PlanSummary extends StatelessWidget {
  final Widget storage;
  final Widget price;
  final Widget featureMobile;
  const PlanSummary({
    super.key,
    required this.storage,
    required this.price,
    required this.featureMobile,
  });

  @override
  Widget build(BuildContext context) {
    return forms.Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(label: Text("storage"), input: storage),
          forms.Field(label: Text("mobile app"), input: featureMobile),
          forms.Field(label: Text("Price"), input: price),
        ],
      ),
    );
  }
}
