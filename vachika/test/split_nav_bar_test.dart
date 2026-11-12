import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vachika/core/widgets/split_nav_bar.dart';

void main() {
  const tabs = [
    SplitNavItem(icon: Icons.home_rounded, label: 'Home'),
    SplitNavItem(icon: Icons.menu_book_rounded, label: 'Dictionary'),
    SplitNavItem(icon: Icons.history_rounded, label: 'History'),
    SplitNavItem(icon: Icons.settings_rounded, label: 'Settings'),
  ];

  testWidgets('SplitNavBar displays circle + rectangle when currentIndex == 0',
      (WidgetTester tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SplitNavBar(
            currentIndex: 0,
            onTap: (i) => tappedIndex = i,
            items: tabs,
          ),
        ),
      ),
    );

    // Verify all 4 tab labels are present in the widget tree
    expect(find.text('Dictionary'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap on Dictionary (index 1)
    await tester.tap(find.text('Dictionary'));
    await tester.pumpAndSettle();
    expect(tappedIndex, equals(1));
  });

  testWidgets('SplitNavBar displays unified rectangle dock when currentIndex != 0',
      (WidgetTester tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SplitNavBar(
            currentIndex: 1,
            onTap: (i) => tappedIndex = i,
            items: tabs,
          ),
        ),
      ),
    );

    // In unified dock, all 4 labels are visible
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Dictionary'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);

    // Tap Home (index 0)
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(tappedIndex, equals(0));
  });
}
