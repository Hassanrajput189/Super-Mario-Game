import 'dart:math';
import 'package:flutter/material.dart';

class Mario extends StatelessWidget {
  final  direction;
  final run;
  final size;
  const Mario({
    super.key,
    this.direction,
    this.run,
    this.size,
  });

  @override
  Widget build(BuildContext context) {
    // Choose the image based on 'run' state
    final String imagePath = run
        ? 'assets/images/running_mario.png'
        : 'assets/images/standing_mario.png';

    // Flip if facing left
    return Transform(
      alignment: Alignment.center,
      transform: direction == "left"
          ? Matrix4.rotationY(pi)
          : Matrix4.identity(),
      child: Image.asset(
        imagePath,
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }
}
