import 'package:flutter/material.dart';

class GradientContainer extends StatelessWidget {
  const GradientContainer({
    super.key,
    required this.colors1,
    required this.colors2,
    this.child,
  });
  final List<Color> colors1;
  final List<Color> colors2;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [...colors1, ...colors2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}
