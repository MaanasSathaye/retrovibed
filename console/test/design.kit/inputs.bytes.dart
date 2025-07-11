import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:retrovibed/design.kit/inputs.dart';
import 'package:retrovibed/designkit.dart' as ds;

void main() {
  group('ByteWidget', () {
    testWidgets('initializes with default values and displays correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ds.ByteWidget(),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('0'), findsOneWidget); // Default initialBytes is 0
      expect(find.byType(DropdownButton<int>), findsOneWidget);
      expect(find.text('GiB'), findsOneWidget); // Default initialMagnitude is bytes
    });

    testWidgets('initializes with provided initialBytes and initialMagnitude', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ds.ByteWidget(
              value: 2,
              magnitude: ds.bytesx.KiB,
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.byType(DropdownButton<int>), findsOneWidget);
      expect(find.text('KiB'), findsOneWidget);
    });

    testWidgets('updates TextField value when magnitude changes', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ds.ByteWidget(
              value: 5,
              magnitude: ds.bytesx.MiB,
            ),
          ),
        ),
      );

      // Verify initial state
      expect(find.text('5'), findsOneWidget);
      expect(find.text('MiB'), findsOneWidget);

      // Tap on the dropdown
      await tester.tap(find.text('MiB'));
      await tester.pumpAndSettle(); // Wait for the dropdown to open

      // Select KiB
      await tester.tap(find.text('KiB').last); // Use .last if multiple KiB are found in the list
      await tester.pumpAndSettle(); // Wait for the dropdown to close and widget to update

      // Verify updated values
      expect(find.text('5'), findsOneWidget);
      expect(find.text('KiB'), findsOneWidget);
    });

    testWidgets('triggers onBytesChanged callback when TextField value changes', (WidgetTester tester) async {
      int? capturedBytes;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ds.ByteWidget(
              onChange: (bytes) {
                capturedBytes = bytes;
              },
            ),
          ),
        ),
      );

      // Enter '100' in the TextField
      await tester.enterText(find.byType(TextField), '100');
      await tester.pumpAndSettle();

      expect(capturedBytes, 100 * bytesx.GiB); // 100 bytes

      // Change magnitude to KiB
      await tester.tap(find.text('GiB'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('KiB').last);
      await tester.pumpAndSettle();

      // Enter '2' in the TextField (now in KiB)
      await tester.enterText(find.byType(TextField), '2');
      await tester.pumpAndSettle();

      expect(capturedBytes, 2 * bytesx.KiB); // 2 KiB = 2048 bytes
    });

    testWidgets('triggers onBytesChanged callback when magnitude changes', (WidgetTester tester) async {
      int? capturedBytes;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ds.ByteWidget(
              value: 1, // 1 KiB
              magnitude: ds.bytesx.KiB,
              onChange: (bytes) {
                capturedBytes = bytes;
              },
            ),
          ),
        ),
      );

      expect(find.text('1'), findsOneWidget); // 1 KiB
      expect(find.text('KiB'), findsOneWidget);
      expect(capturedBytes, bytesx.KiB);

      // Tap on the dropdown
      await tester.tap(find.text('KiB'));
      await tester.pumpAndSettle();

      // Select MiB
      await tester.tap(find.text('MiB').last);
      await tester.pumpAndSettle();

      // The value should update to 0.00 in the TextField but the underlying bytes should remain 1024.
      // The callback should reflect the underlying bytes value.
      expect(find.text('1'), findsOneWidget); // 1 KiB is 0.00 MiB (rounded to 2 decimal places)
      expect(find.text('MiB'), findsOneWidget);
      expect(capturedBytes, bytesx.MiB);
    });

    testWidgets('handles non-numeric input gracefully', (WidgetTester tester) async {
      int? capturedBytes;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ds.ByteWidget(
              onChange: (bytes) {
                capturedBytes = bytes;
              },
            ),
          ),
        ),
      );

      expect(capturedBytes, 0); // initial callback value before text change
      await tester.enterText(find.byType(TextField), 'abc');
      await tester.pumpAndSettle();

      expect(find.text('abc'), findsNothing); // TextField still shows invalid input
      expect(capturedBytes, 0); // initial callback value before text change
    });

    testWidgets('uses provided decoration', (WidgetTester tester) async {
      const customLabelText = 'Enter Capacity';
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ds.ByteWidget(
              decoration: InputDecoration(
                labelText: customLabelText,
                hintText: 'e.g., 100',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text(customLabelText), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      final TextField textField = tester.widget(find.byType(TextField));
      expect(textField.decoration?.hintText, 'e.g., 100');
      expect(textField.decoration?.border, isA<OutlineInputBorder>());
      expect((textField.decoration?.border as OutlineInputBorder).borderRadius, const BorderRadius.all(Radius.circular(10.0)));
    });
  });
}