import 'package:flutter/material.dart';

class AtlasLogo extends StatelessWidget {
  const AtlasLogo({this.size = 96, super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'logo.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }
}
