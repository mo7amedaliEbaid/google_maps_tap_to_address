import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_tap_to_address/google_maps_tap_to_address.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockGoogleMapController extends Mock
    with MockPlatformInterfaceMixin
    implements GoogleMapController {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('GoogleMapsTapToAddress', () {
    testWidgets('renders Google Map and taps to get address',
            (WidgetTester tester) async {
          await tester.pumpWidget(const MaterialApp(
            home: Scaffold(
              body: GoogleMapsTapToAddress(),
            ),
          ));

          expect(find.byType(GoogleMap), findsOneWidget);
          expect(find.byType(CircularProgressIndicator), findsNothing);

          // Simulate a map tap
          final LatLng testLatLng = LatLng(37.7749, -122.4194); // San Francisco coordinates
          final dynamic state = tester.state(find.byType(GoogleMapsTapToAddress));
          await state._onMapDoubleTap(testLatLng);

          // Verify that the address popup appears
          await tester.pumpAndSettle();
          expect(find.text('العنوان'), findsOneWidget);
          expect(find.byType(FadeTransition), findsOneWidget);
        });

    testWidgets('saves address correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: GoogleMapsTapToAddress(),
        ),
      ));

      // Simulate a map tap and saving an address
      final LatLng testLatLng = LatLng(37.7749, -122.4194); // San Francisco coordinates
      final dynamic state = tester.state(find.byType(GoogleMapsTapToAddress));
      await state._onMapDoubleTap(testLatLng);
      await state._handleSaveAddress();

      // Check that the address was saved
      final lastSavedAddress = await state._getLastSavedAddress();
      expect(lastSavedAddress, isNotNull);
      expect(lastSavedAddress, contains('San Francisco'));
    });

    testWidgets('retrieves last saved address', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: GoogleMapsTapToAddress(),
        ),
      ));

      // Simulate saving an address
      final LatLng testLatLng = LatLng(37.7749, -122.4194); // San Francisco coordinates
      final dynamic state = tester.state(find.byType(GoogleMapsTapToAddress));
      await state._onMapDoubleTap(testLatLng);
      await state._handleSaveAddress();

      // Check that the saved address can be retrieved and displayed
      await tester.tap(find.byIcon(Icons.history));
      await tester.pumpAndSettle();

      expect(find.textContaining('San Francisco'), findsOneWidget);
    });
  });
}
