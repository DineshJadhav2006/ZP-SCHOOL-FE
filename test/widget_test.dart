import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_management/main.dart';

void main() {
  testWidgets('App starts test', (WidgetTester tester) async {
    await tester.pumpWidget(const SchoolManagementApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
