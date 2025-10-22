// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:portal_polieduca/main.dart';

void main() {
  testWidgets('PoliEduca app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PoliEducaApp());

    // Verify that login screen elements are present (updated UI).
    expect(find.text('Portal Educacional'), findsOneWidget);
    expect(find.text('MODO DESENVOLVIMENTO'), findsOneWidget);
  expect(find.text('Digite "aluno" ou "professor"'), findsWidgets);
    expect(find.text('Login Rápido'), findsOneWidget);
    expect(find.text('ENTRAR'), findsOneWidget);
  });
}
