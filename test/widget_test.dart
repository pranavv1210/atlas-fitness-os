import 'package:atlas_fitness_os/src/app/navigation/atlas_shell.dart';
import 'package:atlas_fitness_os/src/app/theme/atlas_theme.dart';
import 'package:atlas_fitness_os/src/features/profile/domain/models/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const profile = UserProfile(
    userId: 'test-user',
    email: 'pranav@example.com',
    displayName: 'Pranav',
  );

  Future<void> pumpAtlasShell(WidgetTester tester) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        theme: AtlasTheme.light,
        home: AtlasShell(profile: profile, onSignOut: () async {}),
      ),
    );
  }

  testWidgets('Atlas shell shows primary navigation', (tester) async {
    await pumpAtlasShell(tester);

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Train'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Me'), findsOneWidget);
    expect(find.textContaining('Pranav'), findsOneWidget);
    expect(find.text('Start your journey'), findsOneWidget);
    expect(find.text('Start in Train'), findsOneWidget);
    expect(find.text('Daily Focus'), findsOneWidget);
  });

  testWidgets('Start in Train opens Train tab', (tester) async {
    await pumpAtlasShell(tester);

    await tester.tap(find.text('Start in Train'));
    await tester.pumpAndSettle();

    expect(find.text('First workout'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
  });

  testWidgets('Train tab shows workout logging controls', (tester) async {
    await pumpAtlasShell(tester);

    await tester.tap(find.byIcon(Icons.fitness_center_outlined));
    await tester.pumpAndSettle();

    expect(find.text('First workout'), findsOneWidget);
    expect(find.text('Chest + Triceps'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.textContaining('Tap Add'), findsOneWidget);
    expect(find.text('Save First Workout'), findsOneWidget);

    await tester.ensureVisible(find.text('Add Exercise'));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -140));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Exercise'));
    await tester.pumpAndSettle();

    expect(find.text('Choose Exercise'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsWidgets);
  });
}
