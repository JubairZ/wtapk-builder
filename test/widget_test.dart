import 'package:flutter_test/flutter_test.dart';

import 'package:wtapk_builder/main.dart';

void main() {
  testWidgets('loads native app maker form', (WidgetTester tester) async {
    await tester.pumpWidget(const OfflineBuilderApp());

    expect(find.text('Web to APK Maker'), findsOneWidget);
    expect(find.text('GENERATE WEB TO APK'), findsOneWidget);
  });
}
