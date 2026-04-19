import 'package:flutter/material.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double depth;
  final Color baseColor;
  final BoxShape shape;
  final EdgeInsetsGeometry? padding;
  final bool inset;
  final double? width;
  final double? height;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.depth = 4,
    required this.baseColor,
    this.shape = BoxShape.rectangle,
    this.padding,
    this.inset = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final hsl = HSLColor.fromColor(baseColor);
    final lightShadowColor = hsl.withLightness((hsl.lightness + 0.1).clamp(0.0, 1.0)).toColor();
    final highLightColor = Colors.white.withValues(alpha: 0.5);
    final darkShadowColor = hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
    final deepShadowColor = Colors.black.withValues(alpha: 0.2);

    return Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: baseColor,
        shape: shape,
        borderRadius: shape == BoxShape.rectangle ? BorderRadius.circular(borderRadius) : null,
        boxShadow: inset ? [] : [
          BoxShadow(
            color: darkShadowColor,
            offset: Offset(depth, depth),
            blurRadius: depth * 2,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: deepShadowColor,
            offset: Offset(depth / 2, depth / 2),
            blurRadius: depth,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: lightShadowColor,
            offset: Offset(-depth, -depth),
            blurRadius: depth * 2,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: highLightColor,
            offset: Offset(-depth / 2, -depth / 2),
            blurRadius: depth,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}
