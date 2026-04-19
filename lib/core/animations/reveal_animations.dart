import 'package:flutter/material.dart';

class CounterAnimation extends StatelessWidget {
  final double value;
  final TextStyle style;
  final String suffix;
  final Duration duration;

  const CounterAnimation({
    super.key,
    required this.value,
    this.style = const TextStyle(),
    this.suffix = '',
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: value),
      duration: duration,
      curve: Curves.easeOutExpo,
      builder: (context, val, child) {
        return Text(
          '${val.toStringAsFixed(1)}$suffix',
          style: style,
        );
      },
    );
  }
}

class SuccessReveal extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const SuccessReveal({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 400),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: duration,
      curve: Curves.easeOutBack,
      builder: (context, val, childWidget) {
        return Opacity(
          opacity: val.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.85 + (val * 0.15),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}
