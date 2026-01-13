import 'package:flutter_test/flutter_test.dart';
import 'package:pet_shelter_rush/main.dart';

void main() {
  testWidgets('Pet Shelter Rush app builds', (WidgetTester tester) async {
    // Build the app and trigger a frame.
    await tester.pumpWidget(const PetShelterRushApp());

    // Verify the app initializes without errors.
    expect(find.byType(PetShelterRushApp), findsOneWidget);
  });
}
