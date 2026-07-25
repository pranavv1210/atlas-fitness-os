import 'package:flutter/material.dart';

enum AtlasDestination {
  today(label: 'Today', icon: Icons.today_outlined, selectedIcon: Icons.today),
  train(
    label: 'Train',
    icon: Icons.fitness_center_outlined,
    selectedIcon: Icons.fitness_center,
  ),
  progress(
    label: 'Progress',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
  ),
  goals(label: 'Goals', icon: Icons.flag_outlined, selectedIcon: Icons.flag),
  me(label: 'Me', icon: Icons.person_outline, selectedIcon: Icons.person);

  const AtlasDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
