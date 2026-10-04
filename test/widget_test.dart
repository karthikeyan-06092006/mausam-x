import 'package:flutter_test/flutter_test.dart';
import 'package:mausam_x/main.dart';

void main() {
  testWidgets('MausamXApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MausamXApp());
    expect(find.byType(MausamXApp), findsOneWidget);
  });
}
