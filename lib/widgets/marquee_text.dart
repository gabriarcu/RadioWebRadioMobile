import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class MarqueeText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double velocity;

  const MarqueeText({
    super.key,
    required this.text,
    this.style = const TextStyle(),
    this.velocity = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: style.fontSize! * 1.2,
      child: Marquee(
        text: text,
        style: style,
        velocity: velocity,
        blankSpace: 20.0,
        pauseAfterRound: const Duration(seconds: 1),
        startPadding: 10.0,
        accelerationDuration: const Duration(seconds: 1),
        accelerationCurve: Curves.linear,
        decelerationDuration: const Duration(milliseconds: 500),
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
