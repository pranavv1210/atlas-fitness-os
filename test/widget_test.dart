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

  testWidgets('Atlas shell shows primary navigation', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AtlasTheme.light,
        home: AtlasShell(profile: profile, onSignOut: () async {}),
      ),
    );

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

  testWidgets('Train tab shows workout logging controls', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AtlasTheme.light,
        home: AtlasShell(profile: profile, onSignOut: () async {}),
      ),
    );

    await tester.tap(find.byIcon(Icons.fitness_center_outlined));
    await tester.pumpAndSettle();

    expect(find.text('First workout'), findsOneWidget);
    expect(find.text('Chest + Triceps'), findsOneWidget);
    expect(find.text('Exercises'), findsOneWidget);
    expect(find.text('Barbell Bench Press'), findsWidgets);
    expect(find.text('Save First Workout'), findsOneWidget);
  });
}
