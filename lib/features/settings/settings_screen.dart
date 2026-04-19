import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/style_adaptor.dart';
import '../../core/l10n/app_localizations.dart';
import 'settings_provider.dart';
import 'widgets/engine_settings_panel.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
          child: Column(
            children: [
              // App Bar - One UI Style
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded, 
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.translate('settings_title'),
                      style: GoogleFonts.cairo(
                        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // APPEARANCE SECTION
                        _buildSectionHeader(l10n.translate('theme'), isDark),
                        StyleCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 28,
                          child: Column(
                            children: [
                              _buildSettingRow(
                                icon: Icons.style_rounded,
                                title: l10n.translate('design_style'),
                                trailing: SegmentedButton<AppStyle>(
                                  segments: [
                                    ButtonSegment(value: AppStyle.glass, label: Text(l10n.translate('glass'))),
                                    ButtonSegment(value: AppStyle.neumorph, label: Text(l10n.translate('neumorph'))),
                                  ],
                                  selected: {settings.appStyle},
                                  onSelectionChanged: (val) => ref.read(settingsProvider.notifier).updateAppStyle(val.first),
                                  style: _segmentedButtonStyle(isDark),
                                  showSelectedIcon: false,
                                ),
                                isDark: isDark,
                              ),
                              _buildDivider(isDark, context),
                              _buildSettingRow(
                                icon: Icons.dark_mode_rounded,
                                title: l10n.translate('theme'),
                                trailing: SegmentedButton<ThemeMode>(
                                  segments: [
                                    ButtonSegment(value: ThemeMode.light, label: Text(l10n.translate('light'), style: const TextStyle(fontSize: 10))),
                                    ButtonSegment(value: ThemeMode.dark, label: Text(l10n.translate('dark'), style: const TextStyle(fontSize: 10))),
                                    ButtonSegment(value: ThemeMode.system, label: Text(l10n.translate('system'), style: const TextStyle(fontSize: 10))),
                                  ],
                                  selected: {settings.themeMode},
                                  onSelectionChanged: (val) => ref.read(settingsProvider.notifier).updateThemeMode(val.first),
                                  style: _segmentedButtonStyle(isDark),
                                  showSelectedIcon: false,
                                ),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // LANGUAGE SECTION
                        _buildSectionHeader(l10n.translate('language'), isDark),
                        StyleCard(
                          padding: EdgeInsets.zero,
                          borderRadius: 28,
                          child: _buildSettingRow(
                            icon: Icons.language_rounded,
                            title: l10n.translate('language'),
                            trailing: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: settings.locale.languageCode,
                                dropdownColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                iconEnabledColor: isDark ? AppTheme.accentCyan : AppTheme.accentLight,
                                items: [
                                  DropdownMenuItem(value: 'en', child: Text(l10n.translate('english'), style: const TextStyle(fontSize: 13))),
                                  DropdownMenuItem(value: 'ar', child: Text(l10n.translate('arabic'), style: const TextStyle(fontSize: 13))),
                                ],
                                onChanged: (val) => ref.read(settingsProvider.notifier).updateLocale(Locale(val!)),
                              ),
                            ),
                            isDark: isDark,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // ENGINE SECTION
                        _buildSectionHeader(l10n.translate('engine_settings'), isDark),
                        StyleCard(
                          padding: const EdgeInsets.all(24),
                          borderRadius: 28,
                          child: EngineSettingsPanel(isDark: isDark),
                        ),
                        
                        const SizedBox(height: 60),

                        // RESET BUTTON
                        Center(
                          child: TextButton(
                            onPressed: () => ref.read(settingsProvider.notifier).reset(),
                            style: TextButton.styleFrom(
                              backgroundColor: AppTheme.errorRed.withValues(alpha: 0.1),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(
                              l10n.translate('reset_defaults').toUpperCase(), 
                              style: const TextStyle(color: AppTheme.errorRed, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, right: 16),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.cairo(
          color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
          fontWeight: FontWeight.w800,
          fontSize: 11,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    required Widget trailing,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.cairo(
                color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark, BuildContext context) {
    final isRTL = Directionality.of(context) == TextDirection.rtl;
    return Padding(
      padding: EdgeInsets.only(
        left: isRTL ? 0 : 58, 
        right: isRTL ? 58 : 0,
      ),
      child: Divider(
        height: 1, 
        thickness: 0.5, 
        color: isDark ? Colors.white12 : AppTheme.borderLight,
      ),
    );
  }

  ButtonStyle _segmentedButtonStyle(bool isDark) {
    final accent = isDark ? AppTheme.accentCyan : AppTheme.accentLight;
    return SegmentedButton.styleFrom(
      backgroundColor: Colors.transparent,
      selectedBackgroundColor: accent,
      selectedForegroundColor: isDark ? Colors.black : Colors.white,
      foregroundColor: isDark ? Colors.white60 : Colors.black54,
      textStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
