import 'package:flutter/material.dart';
import 'package:retrovibed/design.kit/forms.dart' as forms;

PlanSummary free() => const PlanSummary(
  // id:
  //     foundation.kDebugMode
  //         ? "price_1RbMBbQ24Bh46y1frv5Jj8J2" // dev
  id: "price_1RbMfLLGpJbWOTHPcZfC1tyP", // production
  key: ValueKey("free"),
  storage: Text("none"),
  bandwidth: Text("none"),
  price: Text("\$0/month"),
  mobile: Text("no"),
);

PlanSummary basic() => const PlanSummary(
  // id:
  //     foundation.kDebugMode
  //         ? "price_1RbMCiQ24Bh46y1freKKOYHa"
  id: "price_1RbMgjLGpJbWOTHPMAgX6j9y",
  key: ValueKey("personal"),
  storage: Text("2TB included + \$0.20 each additional 128 GB"),
  bandwidth: Text("12 GB / month"),
  price: Text("\$4/month"),
  mobile: Text("no"),
);

PlanSummary premium() => const PlanSummary(
  // id:
  //     foundation.kDebugMode
  //         ? "price_1RbMF4Q24Bh46y1fmhthVSgC"
  id: "price_1RbMjyLGpJbWOTHP3Zmkd08T",
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

  static PlanSummary fromID(String id) {
    final _basic = basic();
    final _premium = premium();
    if (id == _basic.id) return _basic;
    if (id == _premium.id) return _premium;
    return free();
  }

  @override
  Widget build(BuildContext context) {
    return forms.Container(
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          forms.Field(label: Text("Price"), input: price),
          forms.Field(label: Text("storage"), input: storage),
          forms.Field(label: Text("bandwidth"), input: Tooltip(
            message: "only related to downloading of archived data, accumulates monthly with a cap of 120 TB.",
            child: bandwidth,
          )),
          forms.Field(label: Text("mobile support"), input: mobile),
        ],
      ),
    );
  }
}
