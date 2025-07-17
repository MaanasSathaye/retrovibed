import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/gestures.dart';
import 'package:retrovibed/designkit.dart' as ds;

void main() {
  testWidgets('Cursor persists over child when loading is false', (WidgetTester tester) async {
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
          child: Center(
            child: ds.Loading(
              TextButton(child: Text('Test Child Widget'), onPressed: (){}),
              loading: false,
            ),
          ),
        ),
    );

    final childFinder = find.text('Test Child Widget');

    expect(childFinder, findsOneWidget);

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.moveTo(tester.getCenter(childFinder));
    await tester.pumpAndSettle();

    final mouseRegionFinder = find.ancestor(
      of: childFinder,
      matching: find.byType(MouseRegion),
    );

    expect(mouseRegionFinder, findsOneWidget);
    final mregion = tester.widget<MouseRegion>(mouseRegionFinder);
    expect(mregion.cursor, SystemMouseCursors.click);
  });
}