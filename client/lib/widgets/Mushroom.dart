import 'package:flutter/material.dart';

class Mushroom extends StatelessWidget {
  const Mushroom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      child: Image.asset("assets/images/mushroom.png"));
  }
}
