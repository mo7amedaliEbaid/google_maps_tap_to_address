import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_tap_to_address/src/last_address_screen.dart';

void main() {
  group('LastAddressScreen', () {
    testWidgets('displays address if available', (WidgetTester tester) async {
      const testAddress = '123 Main Street, San Francisco, CA, USA';

      await tester.pumpWidget(const MaterialApp(
        home: LastAddressScreen(address: testAddress),
      ));

      expect(find.text(testAddress), findsOneWidget);
    });

    testWidgets('displays no address message if address is null',
            (WidgetTester tester) async {
          await tester.pumpWidget(const MaterialApp(
            home: LastAddressScreen(),
          ));

          expect(find.text('No address saved yet.'), findsOneWidget);
        });
  });
}
