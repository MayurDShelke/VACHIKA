import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vachika/core/widgets/split_nav_bar.dart';

void main() {
  const tabs = [
    SplitNavItem(icon: Icons.forum_rounded, label: 'Conversation'),
    SplitNavItem(icon: Icons.back_hand_rounded, label: 'Sign → Speech'),
    SplitNavItem(icon: Icons.translate_rounded, label: 'Text → Sign'),
    SplitNavItem(icon: Icons.person_rounded, label: 'Profile'),
  ];

  testWidgets('SplitNavBar displays Conversation circle + [Sign, Text, Profile] pill dock when currentIndex == 0',
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

    // Verify dock labels
    expect(find.text('Sign → Speech'), findsOneWidget);
    expect(find.text('Text → Sign'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap on Sign → Speech (index 1)
    await tester.tap(find.text('Sign → Speech'));
    await tester.pumpAndSettle();
    expect(tappedIndex, equals(1));
  });

  testWidgets('SplitNavBar displays Conversation circle + Sign circle + [Text, Profile] pill dock when currentIndex == 1',
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

    expect(find.text('Text → Sign'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap Text → Sign (index 2)
    await tester.tap(find.text('Text → Sign'));
    await tester.pumpAndSettle();
    expect(tappedIndex, equals(2));
  });

  testWidgets('SplitNavBar displays [Conversation, Sign] pill dock + Text circle + [Profile] when currentIndex == 2',
      (WidgetTester tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SplitNavBar(
            currentIndex: 2,
            onTap: (i) => tappedIndex = i,
            items: tabs,
          ),
        ),
      ),
    );

    expect(find.text('Conversation'), findsOneWidget);
    expect(find.text('Sign → Speech'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // Tap Conversation (index 0)
    await tester.tap(find.text('Conversation'));
    await tester.pumpAndSettle();
    expect(tappedIndex, equals(0));
  });

  testWidgets('SplitNavBar displays [Conversation, Sign, Text] pill dock + Profile circle when currentIndex == 3',
      (WidgetTester tester) async {
    int? tappedIndex;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          bottomNavigationBar: SplitNavBar(
            currentIndex: 3,
            onTap: (i) => tappedIndex = i,
            items: tabs,
          ),
        ),
      ),
    );

    expect(find.text('Conversation'), findsOneWidget);
    expect(find.text('Sign → Speech'), findsOneWidget);
    expect(find.text('Text → Sign'), findsOneWidget);

    // Tap Sign → Speech (index 1)
    await tester.tap(find.text('Sign → Speech'));
    await tester.pumpAndSettle();
    expect(tappedIndex, equals(1));
  });
}
