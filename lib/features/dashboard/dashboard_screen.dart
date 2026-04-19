import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/animations/particles_painter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/style_adaptor.dart';
import '../../core/l10n/app_localizations.dart';
import '../settings/settings_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const _DashboardContent();
  }
}

class _DashboardContent extends ConsumerWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNeumorph = settings.appStyle == AppStyle.neumorph;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          if (isDark && !isNeumorph) const FloatingParticles(),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  // App Bar / Settings
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.blur_on_rounded, 
                        color: isDark ? AppTheme.accentCyan : AppTheme.accentLight, 
                        size: 32
                      ),
                      IconButton(
                        onPressed: () => context.push('/settings'),
                        icon: Icon(
                          Icons.settings_rounded, 
                          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                          size: 26,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Title Section
                  Text(
                    l10n.translate('app_name'),
                    style: theme.textTheme.headlineLarge?.copyWith(
                      color: isDark ? AppTheme.accentCyan : AppTheme.accentLight,
                      letterSpacing: 4.0,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Refined Tagline with Bold/Light Contrast (Cairo)
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        l10n.translate('tagline_part1'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700, // Bold
                          fontSize: 14,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l10n.translate('tagline_part2'),
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w300, // Light
                          fontSize: 14,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Action Cards
                  _DashboardCard(
                    title: l10n.translate('encode'),
                    subtitle: l10n.translate('encode_subtitle'),
                    badge: l10n.translate('encode_badge'),
                    icon: Icons.image_rounded,
                    color: isDark ? AppTheme.accentCyan : AppTheme.accentLight,
                    onTap: () => context.push('/encode'),
                  ),
                  
                  const SizedBox(height: 16),

                  _DashboardCard(
                    title: l10n.translate('audio'),
                    subtitle: l10n.translate('vocal_message'),
                    badge: l10n.translate('audio_badge'),
                    icon: Icons.mic_rounded,
                    color: Colors.orangeAccent,
                    onTap: () => context.push('/audio_encode'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  _DashboardCard(
                    title: l10n.translate('receive'),
                    subtitle: l10n.translate('decode_subtitle'),
                    badge: l10n.translate('decode_badge'),
                    icon: Icons.download_rounded,
                    color: AppTheme.accentPurple,
                    onTap: () => context.push('/decode'),
                  ),
                  
                  const Spacer(),
                  
                  // Developer Branding Footer per User Requirement
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32.0),
                    child: Text(
                      ' by❤️ Mosab_Soft',
                      style: GoogleFonts.cairo(
                        color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: StyleCard(
        padding: const EdgeInsets.all(24),
        borderRadius: 28, // Using 28px for One UI cards
        child: Row(
          children: [
            // Icon container with 10% tint background in Light Mode
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12), // 12px for badges
                        ),
                        child: Text(
                          badge,
                          style: GoogleFonts.outfit(
                            color: color,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            // Indication Icon - plain in One UI style
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white12 : Colors.black12,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
