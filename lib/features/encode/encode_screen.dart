import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/animations/scrolling_ticker.dart';
import '../../core/animations/reveal_animations.dart';
import '../../core/widgets/error_dialog.dart';
import '../../core/widgets/style_adaptor.dart';
import '../../core/l10n/app_localizations.dart';
import '../settings/settings_provider.dart';
import '../settings/widgets/engine_settings_panel.dart';
import 'encode_provider.dart';
import 'dart:ui';

class EncodeScreen extends ConsumerWidget {
  const EncodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(encodeProvider);
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isNeumorph = settings.appStyle == AppStyle.neumorph;
    final accentColor = isDark ? AppTheme.accentCyan : AppTheme.accentLight;

    // Listen for errors to show Dialog
    ref.listen(encodeProvider, (previous, next) {
      if (next.status == EncodeStatus.error && next.error != null) {
        ErrorDialog.show(
          context,
          next.error!,
          () => ref.read(encodeProvider.notifier).reset(),
          actionLabel: l10n.translate('error_retry'),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Ticker background during processing
          if (state.status == EncodeStatus.processing && !isNeumorph)
            ScrollingTicker(textColor: accentColor),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: isDark
                                  ? AppTheme.textPrimaryDark
                                  : AppTheme.textPrimaryLight,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.translate('encode_title'),
                            style: GoogleFonts.cairo(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (state.status == EncodeStatus.idle)
                            IconButton(
                              onPressed: () => _showQuickSettings(context, isDark),
                              icon: Icon(Icons.tune_rounded, color: accentColor, size: 24),
                            ),
                          if (state.status == EncodeStatus.done)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () {
                                  ref.read(encodeProvider.notifier).reset();
                                  HapticFeedback.lightImpact();
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: accentColor.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_photo_alternate_rounded,
                                          color: accentColor, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        l10n.translate('compress_another').toUpperCase(),
                                        style: GoogleFonts.cairo(
                                          color: accentColor,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 10,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Main Interactive Area
                  Expanded(
                    child: Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: _buildMainContent(context, ref, state, l10n,
                                theme, accentColor, isDark),
                          ),
                        ),

                        // Statistics Area (Visible when processing or done)
                        if (state.status == EncodeStatus.processing ||
                            state.status == EncodeStatus.done)
                          Padding(
                            padding: const EdgeInsets.only(top: 20, bottom: 20),
                            child: _buildStatsContainer(
                                state, l10n, theme, isDark, accentColor),
                          ),
                      ],
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

  Widget _buildMainContent(
      BuildContext context,
      WidgetRef ref,
      EncodeState state,
      AppLocalizations l10n,
      ThemeData theme,
      Color accentColor,
      bool isDark) {
    switch (state.status) {
      case EncodeStatus.idle:
        return _buildPickerUI(
            () => ref.read(encodeProvider.notifier).processImage(),
            l10n,
            theme,
            accentColor,
            isDark);
      case EncodeStatus.picking:
      case EncodeStatus.processing:
        return _buildProcessingUI(state, theme, accentColor, l10n, isDark);
      case EncodeStatus.done:
        return _buildSuccessUI(
            context, ref, state, theme, l10n, accentColor, isDark);
      case EncodeStatus.error:
        return _buildPickerUI(
            () => ref.read(encodeProvider.notifier).processImage(),
            l10n,
            theme,
            accentColor,
            isDark);
    }
  }

  Widget _buildPickerUI(VoidCallback onPick, AppLocalizations l10n,
      ThemeData theme, Color accentColor, bool isDark) {
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(28),
      child: StyleCard(
        width: double.infinity,
        height: 250,
        borderRadius: 28,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate_rounded,
                size: 60, color: accentColor),
            const SizedBox(height: 20),
            Text(
              l10n.translate('encode_subtitle'),
              style: GoogleFonts.cairo(
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.translate('resolution_label').toUpperCase()} 1280PX',
              style: TextStyle(
                  color: isDark
                      ? AppTheme.textSecondaryDark.withValues(alpha: 0.5)
                      : AppTheme.textSecondaryLight.withValues(alpha: 0.5),
                  fontSize: 10,
                  letterSpacing: 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingUI(EncodeState state, ThemeData theme,
      Color accentColor, AppLocalizations l10n, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(color: accentColor, strokeWidth: 2),
        const SizedBox(height: 30),
        Text(
          l10n.translate('processing').toUpperCase(),
          style: GoogleFonts.cairo(
            color: accentColor,
            fontWeight: FontWeight.w700,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '${(state.progress * 100).toInt()}% ${l10n.translate('complete').toUpperCase()}',
          style: TextStyle(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontSize: 11,
              fontFamily: 'Monospace'),
        ),
      ],
    );
  }

  Widget _buildSuccessUI(BuildContext context, WidgetRef ref, EncodeState state,
      ThemeData theme, AppLocalizations l10n, Color accentColor, bool isDark) {
    return SuccessReveal(
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 48, color: AppTheme.successGreen),
          const SizedBox(height: 12),
          Text(
            l10n.translate('chunks_ready').toUpperCase(),
            style: GoogleFonts.cairo(
              color:
                  isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${state.chunks.length} ${l10n.translate('captured_chunks').toUpperCase()}',
            style: TextStyle(
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                fontSize: 11),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              itemCount: state.chunks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _ChunkCard(
                index: index + 1,
                total: state.chunks.length,
                content: state.chunks[index],
                accentColor: accentColor,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContainer(EncodeState state, AppLocalizations l10n,
      ThemeData theme, bool isDark, Color accentColor) {
    return StyleCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      child: Column(
        children: [
          _buildStatRow(
              l10n.translate('original_size').toUpperCase(),
              state.originalSize / 1024,
              ' KB',
              isDark,
              isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight),
          Divider(
              color: isDark ? Colors.white10 : AppTheme.borderLight,
              height: 24),
          _buildStatRow(l10n.translate('final_text').toUpperCase(),
              state.compressedSize / 1024, ' KB', isDark, accentColor),
          if (state.status == EncodeStatus.done) ...[
            Divider(
                color: isDark ? Colors.white10 : AppTheme.borderLight,
                height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.translate('reduction').toUpperCase(),
                    style: TextStyle(
                        color: isDark
                            ? AppTheme.textSecondaryDark.withValues(alpha: 0.5)
                            : AppTheme.textSecondaryLight
                                .withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                Text(
                  '${state.compressionRatio.toStringAsFixed(1)}%',
                  style: const TextStyle(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w900,
                      fontSize: 20),
                ),
              ],
            ),
            Divider(color: isDark ? Colors.white10 : AppTheme.borderLight, height: 24),
            _buildStatRow(
                l10n.translate('conversion_time').toUpperCase(),
                state.encodingDurationMs.toDouble(),
                ' MS',
                isDark,
                accentColor),
            Divider(color: isDark ? Colors.white10 : AppTheme.borderLight, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(l10n.translate('total_chars').toUpperCase(),
                    style: TextStyle(
                        color: isDark
                            ? AppTheme.textSecondaryDark.withValues(alpha: 0.5)
                            : AppTheme.textSecondaryLight.withValues(alpha: 0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
                Text(
                  '${state.totalCharacters}',
                  style: TextStyle(
                      color: accentColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      fontFamily: 'Monospace'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, double value, String suffix, bool isDark,
      Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                color: isDark
                    ? AppTheme.textSecondaryDark.withValues(alpha: 0.5)
                    : AppTheme.textSecondaryLight.withValues(alpha: 0.5),
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        Text(
          '${value.toStringAsFixed(1)}$suffix',
          style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w900,
              fontSize: 13,
              fontFamily: 'Monospace'),
        ),
      ],
    );
  }

  void _showQuickSettings(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.fromLTRB(28, 20, 28, 40),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.8),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.tune_rounded, color: isDark ? AppTheme.accentCyan : AppTheme.accentLight, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    AppLocalizations.of(context).translate('engine_settings'),
                    style: GoogleFonts.cairo(
                      color: isDark ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              EngineSettingsPanel(isDark: isDark, physics: const NeverScrollableScrollPhysics()),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChunkCard extends StatefulWidget {
  final int index;
  final int total;
  final String content;
  final Color accentColor;
  final bool isDark;

  const _ChunkCard({
    required this.index,
    required this.total,
    required this.content,
    required this.accentColor,
    required this.isDark,
  });

  @override
  State<_ChunkCard> createState() => _ChunkCardState();
}

class _ChunkCardState extends State<_ChunkCard> {
  bool _copied = false;

  void _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.content));
    if (!mounted) return;
    setState(() => _copied = true);
    HapticFeedback.mediumImpact();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }


  @override
  Widget build(BuildContext context) {
    final String preview = widget.content.length > 30
        ? '${widget.content.substring(0, 30)}...'
        : widget.content;
    final l10n = AppLocalizations.of(context);

    return StyleCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Column(
        children: [
          // Header row: chunk index + preview
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${widget.index}/${widget.total}',
                  style: TextStyle(
                    color: widget.accentColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    fontFamily: 'Monospace',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  preview,
                  style: TextStyle(
                    color: widget.isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                    fontFamily: 'Monospace',
                    fontSize: 10,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const SizedBox(height: 12),
          // Action button: Animated Distinct Copy
          InkWell(
            onTap: _copied ? null : _copy,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _copied
                    ? AppTheme.successGreen.withValues(alpha: 0.1)
                    : widget.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _copied
                      ? AppTheme.successGreen
                      : widget.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _copied ? Icons.check_circle_rounded : Icons.copy_all_rounded,
                    color: _copied ? AppTheme.successGreen : widget.accentColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _copied ? l10n.translate('copied').toUpperCase() : l10n.translate('copy').toUpperCase(),
                    style: TextStyle(
                      color: _copied ? AppTheme.successGreen : widget.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
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
