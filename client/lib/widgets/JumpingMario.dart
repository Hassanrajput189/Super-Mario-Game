import 'package:flutter/material.dart';
import 'dart:math';

class JumpingMario extends StatelessWidget {
  final direction;
  final size;
  const JumpingMario({super.key, this.direction, this.size});

  @override
  Widget build(BuildContext context) {
    if (direction == "right") {
      return Container(
        width: size,
        height: size,
        child: Image.asset("assets/images/jumping_mario.png"),
      );
    } else {
      return Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(pi),
        child: Container(
          width: size,
          height: size,
          child: Image.asset("assets/images/jumping_mario.png"),
        ),
      );
    }
  }
}
