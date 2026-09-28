// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:commitment_app/main.dart';

void main() {
  testWidgets('welcome screen displays the app flow', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('COMMITMENT APP'), findsWidgets);
    expect(find.text('SIGN UP'), findsOneWidget);
  });

  testWidgets('signup flow can move to the mobile input screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('SIGN UP'));
    await tester.pumpAndSettle();

    expect(find.text('Enter mobile/email'), findsOneWidget);
  });
}
