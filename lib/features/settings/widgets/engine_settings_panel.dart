import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/l10n/app_localizations.dart';
import '../settings_provider.dart';

class EngineSettingsPanel extends ConsumerWidget {
  final bool isDark;
  final ScrollPhysics? physics;

  const EngineSettingsPanel({
    super.key,
    required this.isDark,
    this.physics,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final accent = isDark ? AppTheme.accentCyan : AppTheme.accentLight;

    return SingleChildScrollView(
      physics: physics,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // QUALITY SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('quality_label'),
                style: GoogleFonts.cairo(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${settings.webpQuality}%',
                style: TextStyle(
                  color: accent,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: settings.webpQuality.toDouble(),
            min: 10,
            max: 100,
            divisions: 18,
            activeColor: accent,
            inactiveColor: isDark ? Colors.white12 : Colors.black12,
            onChanged: (val) {
              ref.read(settingsProvider.notifier).updateQuality(val.toInt());
              if (val.toInt() % 10 == 0) HapticFeedback.selectionClick();
            },
          ),

          const SizedBox(height: 24),
          Divider(color: isDark ? Colors.white12 : Colors.black12, thickness: 1),
          const SizedBox(height: 24),

          // RESOLUTION SECTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('resolution_label'),
                style: GoogleFonts.cairo(
                  color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  canvasColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
                child: DropdownButton<int>(
                  value: [480, 800, 1280, 1600, 2048].contains(settings.maxDimension)
                      ? settings.maxDimension
                      : 1280,
                  dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  underline: const SizedBox(),
                  icon: Icon(Icons.keyboard_arrow_down_rounded, color: accent),
                  style: GoogleFonts.cairo(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                  items: [
                    DropdownMenuItem(value: 480, child: Text(l10n.translate('res_very_low'))),
                    DropdownMenuItem(value: 800, child: Text(l10n.translate('res_low'))),
                    DropdownMenuItem(value: 1280, child: Text(l10n.translate('res_medium'))),
                    DropdownMenuItem(value: 1600, child: Text(l10n.translate('res_high'))),
                    DropdownMenuItem(value: 2048, child: Text(l10n.translate('res_ultra'))),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      ref.read(settingsProvider.notifier).updateMaxDimension(val);
                      HapticFeedback.lightImpact();
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
