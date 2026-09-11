import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Prefer bundled photos so workout lists also render offline.
class AtlasExerciseImage extends StatelessWidget {
  const AtlasExerciseImage({
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.fadeInDuration = const Duration(milliseconds: 180),
    this.placeholder,
    this.errorWidget,
    super.key,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Duration fadeInDuration;
  final Widget Function(BuildContext, String)? placeholder;
  final Widget Function(BuildContext, String, Object)? errorWidget;

  @override
  Widget build(BuildContext context) {
    final uri = Uri.tryParse(imageUrl);
    final parts = uri?.pathSegments ?? const <String>[];
    Widget network() => CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      placeholder: placeholder,
      errorWidget:
          errorWidget ??
          (_, __, ___) => SizedBox(
            width: width,
            height: height,
            child: const Icon(Icons.fitness_center_rounded),
          ),
    );
    if (uri?.host == 'raw.githubusercontent.com' &&
        parts.contains('free-exercise-db') &&
        parts.length >= 2) {
      final sourceId = parts[parts.length - 2];
      final id =
          const {
            'Barbell_Bench_Press': 'Barbell_Bench_Press_-_Medium_Grip',
            'Incline_Dumbbell_Bench_Press': 'Incline_Dumbbell_Press',
            'Triceps_Dip': 'Dips_-_Chest_Version',
            'Lat_Pulldown': 'Wide-Grip_Lat_Pulldown',
            'Seated_Cable_Row': 'Seated_Cable_Rows',
            'Dumbbell_Lateral_Raise': 'Side_Lateral_Raise',
          }[sourceId] ??
          sourceId;
      return Image.asset(
        'assets/exercises/$id.webp',
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => network(),
      );
    }
    return network();
  }
}
