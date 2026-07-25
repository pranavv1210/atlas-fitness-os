import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/atlas_colors.dart';
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
      bottomNavigationBar: _FloatingDock(
        destinations: destinations,
        selectedIndex: _selectedIndex,
        onSelected: (index) {
          if (index != _selectedIndex) {
            HapticFeedback.selectionClick();
          }
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildScreen(AtlasDestination destination) {
    switch (destination) {
      case AtlasDestination.today:
        return TodayScreen(profile: widget.profile);
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

class _FloatingDock extends StatelessWidget {
  const _FloatingDock({
    required this.destinations,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<AtlasDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(34),
              border: Border.all(color: Colors.white.withValues(alpha: 0.58)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  for (var index = 0; index < destinations.length; index++)
                    Expanded(
                      child: _DockItem(
                        destination: destinations[index],
                        isSelected: index == selectedIndex,
                        onTap: () => onSelected(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockItem extends StatelessWidget {
  const _DockItem({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  final AtlasDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : const Color(0xFF68645E);
    return Semantics(
      selected: isSelected,
      button: true,
      label: destination.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          height: 58,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient:
                isSelected
                    ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AtlasColors.accent, AtlasColors.accentDeep],
                    )
                    : null,
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AtlasColors.accent.withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 10),
                      ),
                    ]
                    : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.08 : 1,
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutBack,
                child: Icon(
                  isSelected ? destination.selectedIcon : destination.icon,
                  color: color,
                  size: isSelected ? 23 : 22,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
