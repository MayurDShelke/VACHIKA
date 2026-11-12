import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vachika/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: VachikaApp()));
    await tester.pumpAndSettle();
    expect(find.byType(VachikaApp), findsOneWidget);
  });
}
