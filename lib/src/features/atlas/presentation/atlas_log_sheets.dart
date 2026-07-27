import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/theme/atlas_colors.dart';
import '../../../core/widgets/atlas_gradient_button.dart';
import '../../../core/widgets/atlas_pressable.dart';
import '../../../core/widgets/section_title.dart';
import '../data/atlas_data_repository.dart';

const cardioOptions = [
  'Walking',
  'Running',
  'Cycling',
  'Indoor Cycling',
  'Swimming',
  'Elliptical',
  'HIIT',
  'Rowing',
  'Skipping Rope',
  'Stair Climber',
  'Hiking',
  'Treadmill',
];

const sportOptions = [
  'Badminton',
  'Football',
  'Basketball',
  'Cricket',
  'Pickleball',
  'Table Tennis',
  'Tennis',
  'Squash',
  'Volleyball',
  'Boxing',
  'Martial Arts',
  'Yoga',
  'Pilates',
];

Future<bool> showAtlasWeightLogSheet(
  BuildContext context, {
  required AtlasDataRepository? repository,
}) async {
  final weightController = TextEditingController();
  final noteController = TextEditingController();
  var measuredOn = DateTime.now();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (context) => StatefulBuilder(
          builder:
              (context, setSheetState) => _AtlasLogSheet(
                title: 'Log Weight',
                subtitle: 'One clean measurement for your trend.',
                saveLabel: 'Save Weight',
                onSave: () async {
                  final weight = double.tryParse(weightController.text);
                  if (repository == null || weight == null || weight <= 0) {
                    HapticFeedback.selectionClick();
                    return;
                  }
                  await repository.saveWeight(
                    weight,
                    note: noteController.text,
                    measuredOn: measuredOn,
                  );
                  if (context.mounted) Navigator.pop(context, true);
                },
                children: [
                  _PremiumTextField(
                    controller: weightController,
                    label: 'Weight',
                    suffix: 'kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DateSelector(
                    date: measuredOn,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: measuredOn,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setSheetState(() => measuredOn = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _PremiumTextField(
                    controller: noteController,
                    label: 'Note',
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
        ),
  );

  return saved ?? false;
}

Future<bool> showAtlasCardioLogSheet(
  BuildContext context, {
  required AtlasDataRepository? repository,
}) async {
  final activity = await showAtlasOptionPicker(
    context,
    title: 'Choose Cardio',
    options: cardioOptions,
    iconForOption: cardioIcon,
  );
  if (activity == null || !context.mounted) return false;

  final minutesController = TextEditingController(text: '30');
  final distanceController = TextEditingController();
  final caloriesController = TextEditingController();

  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (context) => _AtlasLogSheet(
          title: activity,
          subtitle: 'Cardio session details.',
          saveLabel: 'Save Cardio',
          onSave: () async {
            final minutes = int.tryParse(minutesController.text) ?? 0;
            if (repository == null || minutes <= 0) return;
            await repository.saveCardio(
              activityType: activity,
              durationMinutes: minutes,
              distance: double.tryParse(distanceController.text),
              calories: double.tryParse(caloriesController.text),
            );
            if (context.mounted) Navigator.pop(context, true);
          },
          children: [
            _PremiumTextField(
              controller: minutesController,
              label: 'Minutes',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PremiumTextField(
                    controller: distanceController,
                    label: 'Distance',
                    suffix: 'km',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PremiumTextField(
                    controller: caloriesController,
                    label: 'Calories',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
  );
  return saved ?? false;
}

Future<bool> showAtlasSportLogSheet(
  BuildContext context, {
  required AtlasDataRepository? repository,
}) async {
  final sport = await showAtlasOptionPicker(
    context,
    title: 'Choose Sport',
    options: sportOptions,
    iconForOption: sportIcon,
  );
  if (sport == null || !context.mounted) return false;

  final minutesController = TextEditingController(text: '30');
  final saved = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (context) => _AtlasLogSheet(
          title: sport,
          subtitle: 'Sport session duration.',
          saveLabel: 'Save Sport',
          onSave: () async {
            final minutes = int.tryParse(minutesController.text) ?? 0;
            if (repository == null || minutes <= 0) return;
            await repository.saveSport(
              sportName: sport,
              durationMinutes: minutes,
            );
            if (context.mounted) Navigator.pop(context, true);
          },
          children: [
            _PremiumTextField(
              controller: minutesController,
              label: 'Minutes',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
  );
  return saved ?? false;
}

Future<String?> showAtlasOptionPicker(
  BuildContext context, {
  required String title,
  required List<String> options,
  required IconData Function(String option) iconForOption,
}) {
  final searchController = TextEditingController();
  var query = '';

  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder:
        (context) => StatefulBuilder(
          builder: (context, setSheetState) {
            final filtered =
                options
                    .where(
                      (option) =>
                          option.toLowerCase().contains(query.toLowerCase()),
                    )
                    .toList();
            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                4,
                20,
                MediaQuery.paddingOf(context).bottom + 22,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(title),
                  const SizedBox(height: 12),
                  _PremiumTextField(
                    controller: searchController,
                    label: 'Search',
                    keyboardType: TextInputType.text,
                    onChanged: (value) => setSheetState(() => query = value),
                  ),
                  const SizedBox(height: 14),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(context).height * 0.58,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final option = filtered[index];
                        final icon = iconForOption(option);
                        return AtlasPressable(
                          onTap: () => Navigator.pop(context, option),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(color: AtlasColors.hairline),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: AtlasColors.accent.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(icon, color: AtlasColors.accent),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    option,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: filtered.length,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
  );
}

IconData cardioIcon(String activity) {
  return switch (activity) {
    'Walking' => Icons.directions_walk_rounded,
    'Running' => Icons.directions_run_rounded,
    'Cycling' => Icons.directions_bike_rounded,
    'Indoor Cycling' => Icons.pedal_bike_rounded,
    'Swimming' => Icons.pool_rounded,
    'Elliptical' => Icons.fitness_center_rounded,
    'HIIT' => Icons.bolt_rounded,
    'Rowing' => Icons.rowing_rounded,
    'Skipping Rope' => Icons.sports_gymnastics_rounded,
    'Stair Climber' => Icons.stairs_rounded,
    'Hiking' => Icons.hiking_rounded,
    'Treadmill' => Icons.directions_run_rounded,
    _ => Icons.directions_run_rounded,
  };
}

IconData sportIcon(String sport) {
  return switch (sport) {
    'Badminton' => Icons.sports_tennis_rounded,
    'Football' => Icons.sports_soccer_rounded,
    'Basketball' => Icons.sports_basketball_rounded,
    'Cricket' => Icons.sports_cricket_rounded,
    'Pickleball' => Icons.sports_tennis_rounded,
    'Table Tennis' => Icons.sports_tennis_rounded,
    'Tennis' => Icons.sports_tennis_rounded,
    'Squash' => Icons.sports_tennis_rounded,
    'Volleyball' => Icons.sports_volleyball_rounded,
    'Boxing' => Icons.sports_mma_rounded,
    'Martial Arts' => Icons.sports_martial_arts_rounded,
    'Yoga' => Icons.self_improvement_rounded,
    'Pilates' => Icons.accessibility_new_rounded,
    _ => Icons.sports_rounded,
  };
}

class _AtlasLogSheet extends StatelessWidget {
  const _AtlasLogSheet({
    required this.title,
    required this.subtitle,
    required this.children,
    required this.saveLabel,
    required this.onSave,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final String saveLabel;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        4,
        22,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            22,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 18),
          ...children,
          const SizedBox(height: 20),
          AtlasGradientButton(
            label: saveLabel,
            icon: Icons.check_rounded,
            onPressed: onSave,
          ),
        ],
      ),
    );
  }
}

class _PremiumTextField extends StatelessWidget {
  const _PremiumTextField({
    required this.controller,
    required this.label,
    required this.keyboardType,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? suffix;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        filled: true,
        fillColor: Theme.of(context).colorScheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AtlasColors.hairline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: AtlasColors.hairline),
        ),
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({required this.date, required this.onTap});

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AtlasPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AtlasColors.hairline),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const Icon(Icons.expand_more_rounded),
          ],
        ),
      ),
    );
  }
}
