import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../theme/glass_container.dart';
import '../theme/neumorphic_container.dart';
import '../../features/settings/settings_provider.dart';

class StyleCard extends ConsumerWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final Color? color;
  final bool isButton;
  final double? width;
  final double? height;

  const StyleCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
    this.isButton = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final theme = Theme.of(context);
    
    final effectiveRadius = borderRadius ?? (isButton ? 16.0 : 28.0);

    if (settings.appStyle == AppStyle.neumorph) {
      final baseColor = AppTheme.getNeumorphicBase(theme.brightness);
      return NeumorphicContainer(
        baseColor: baseColor,
        borderRadius: effectiveRadius,
        padding: padding,
        width: width,
        height: height,
        child: child,
      );
    } else {
      return GlassContainer(
        padding: padding,
        borderRadius: effectiveRadius,
        color: color,
        width: width,
        height: height,
        child: child,
      );
    }
  }
}
