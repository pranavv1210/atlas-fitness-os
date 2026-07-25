import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../features/goals/presentation/goals_screen.dart';
import '../../features/me/presentation/me_screen.dart';
import '../../features/profile/domain/models/user_profile.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/today/presentation/today_screen.dart';
import '../../features/train/presentation/train_screen.dart';
import 'atlas_destination.dart';

class AtlasShell extends StatefulWidget {
  const AtlasShell({required this.profile, required this.onSignOut, super.key});

  final UserProfile profile;
  final Future<void> Function() onSignOut;

  @override
  State<AtlasShell> createState() => _AtlasShellState();
}

class _AtlasShellState extends State<AtlasShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final destinations = AtlasDestination.values;

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 360),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          final offset = Tween<Offset>(
            begin: const Offset(0.03, 0.015),
            end: Offset.zero,
          ).animate(curved);

          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.985, end: 1).animate(curved),
              child: SlideTransition(position: offset, child: child),
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_selectedIndex),
          child: _buildScreen(destinations[_selectedIndex]),
        ),
      ),
      bottomNavigationBar: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              if (index != _selectedIndex) {
                HapticFeedback.selectionClick();
              }
              setState(() => _selectedIndex = index);
            },
            destinations: [
              for (final destination in destinations)
                NavigationDestination(
                  icon: Icon(destination.icon),
                  selectedIcon: Icon(destination.selectedIcon),
                  label: destination.label,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreen(AtlasDestination destination) {
    switch (destination) {
      case AtlasDestination.today:
        return const TodayScreen();
      case AtlasDestination.train:
        return const TrainScreen();
      case AtlasDestination.progress:
        return const ProgressScreen();
      case AtlasDestination.goals:
        return const GoalsScreen();
      case AtlasDestination.me:
        return MeScreen(profile: widget.profile, onSignOut: widget.onSignOut);
    }
  }
}
