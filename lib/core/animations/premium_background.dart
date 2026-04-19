import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PremiumBackground extends StatefulWidget {
  final Widget? child;
  const PremiumBackground({super.key, this.child});

  @override
  State<PremiumBackground> createState() => _PremiumBackgroundState();
}

class _PremiumBackgroundState extends State<PremiumBackground> with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<Blob> _blobs = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Create blobs with different colors from AppTheme
    _blobs.add(Blob(color: AppTheme.accentCyan, size: 300, speed: 0.1));
    _blobs.add(Blob(color: AppTheme.accentPurple, size: 400, speed: 0.08));
    _blobs.add(Blob(color: AppTheme.accentBlue, size: 350, speed: 0.12));
    _blobs.add(Blob(color: AppTheme.accentLight, size: 250, speed: 0.05));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Base Background
        Container(
          color: isDark ? AppTheme.darkBackground : AppTheme.surfaceLight,
        ),
        
        // Moving Blobs
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: _blobs.map((blob) {
                final double time = _controller.value * 2 * pi;
                final double x = 0.5 + 0.3 * sin(time * blob.speed + blob.initialOffset);
                final double y = 0.5 + 0.3 * cos(time * blob.speed * 1.5 + blob.initialOffset);

                return Positioned(
                  left: x * MediaQuery.of(context).size.width - (blob.size / 2),
                  top: y * MediaQuery.of(context).size.height - (blob.size / 2),
                  child: Container(
                    width: blob.size,
                    height: blob.size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: blob.color.withValues(alpha: isDark ? 0.08 : 0.12),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),

        // Blur Layer
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80, tileMode: TileMode.mirror),
            child: Container(color: Colors.transparent),
          ),
        ),

        if (widget.child != null) widget.child!,
      ],
    );
  }
}

class Blob {
  final Color color;
  final double size;
  final double speed;
  late double initialOffset;

  Blob({required this.color, required this.size, required this.speed}) {
    initialOffset = Random().nextDouble() * 2 * pi;
  }
}
