import 'package:flutter_test/flutter_test.dart';
import 'package:phylactere/app/phylactere_app.dart';

void main() {
  testWidgets('shows initial editor actions', (tester) async {
    await tester.pumpWidget(const PhylactereApp());

    expect(find.text('Phylactère'), findsOneWidget);
    expect(find.text('Choisir une photo'), findsOneWidget);
    expect(find.text('Bulle'), findsOneWidget);
  });
}
