// ignore_for_file: experimental_member_use
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/animations/arc_progress_painter.dart';
import '../../core/animations/reveal_animations.dart';
import '../../core/widgets/error_dialog.dart';
import '../../core/widgets/style_adaptor.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/constants/app_constants.dart';
import 'audio_encode_provider.dart';

class AudioEncodeScreen extends ConsumerWidget {
  const AudioEncodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(audioEncodeProvider);
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? AppTheme.accentCyan : AppTheme.accentLight;

    // Listen for errors
    ref.listen(audioEncodeProvider, (previous, next) {
      if (next.status == AudioEncodeStatus.error && next.error != null) {
        ErrorDialog.show(
          context,
          next.error!,
          () => ref.read(audioEncodeProvider.notifier).reset(),
          actionLabel: l10n.translate('error_retry'),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
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
                          color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.translate('audio').toUpperCase(),
                        style: GoogleFonts.cairo(
                          color: accentColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  if (state.status == AudioEncodeStatus.done)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: InkWell(
                        onTap: () {
                          ref.read(audioEncodeProvider.notifier).reset();
                          HapticFeedback.lightImpact();
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: accentColor.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.mic_none_rounded, size: 16, color: accentColor),
                              const SizedBox(width: 8),
                              Text(
                                l10n.translate('new_recording').toUpperCase(),
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
              const SizedBox(height: 40),
              
              Expanded(
                child: _buildMainContent(context, ref, state, l10n, theme, accentColor, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(
    BuildContext context,
    WidgetRef ref,
    AudioEncodeState state,
    AppLocalizations l10n,
    ThemeData theme,
    Color accentColor,
    bool isDark,
  ) {
    switch (state.status) {
      case AudioEncodeStatus.idle:
      case AudioEncodeStatus.recording:
        return _buildRecordingUI(ref, state, l10n, theme, accentColor, isDark);
      case AudioEncodeStatus.processing:
        return _buildProcessingUI(accentColor, l10n);
      case AudioEncodeStatus.done:
        return _buildSuccessUI(context, ref, state, l10n, theme, accentColor, isDark);
      case AudioEncodeStatus.error:
        return _buildRecordingUI(ref, state, l10n, theme, accentColor, isDark);
    }
  }

  Widget _buildRecordingUI(
    WidgetRef ref,
    AudioEncodeState state,
    AppLocalizations l10n,
    ThemeData theme,
    Color accentColor,
    bool isDark,
  ) {
    const int maxSecs = AppConstants.maxRecordingSeconds;
    final bool isRecording = state.status == AudioEncodeStatus.recording;
    final double progress = state.elapsedSeconds / maxSecs;
    
    // Formatting time MM:SS
    final String minutes = (state.elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final String seconds = (state.elapsedSeconds % 60).toString().padLeft(2, '0');
    final String totalMinutes = (maxSecs ~/ 60).toString().padLeft(2, '0');
    final String totalSeconds = (maxSecs % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.translate('vocal_message').toUpperCase(),
          style: GoogleFonts.cairo(
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            fontWeight: FontWeight.w900,
            fontSize: 24,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 40),
        
        // Circular Record Button with Progress Ring
        Stack(
          alignment: Alignment.center,
          children: [
            if (isRecording)
              _WaveVisualizer(amplitude: state.currentAmplitude, color: AppTheme.accentCyan),

            // Progress Ring
            SizedBox(
              width: 220,
              height: 220,
              child: GlowingArcProgress(
                progress: progress,
                size: 220,
                color: isRecording ? AppTheme.accentCyan : accentColor.withValues(alpha: 0.3),
              ),
            ),
            
            // Interaction Button
            GestureDetector(
              onTap: isRecording 
                ? () => ref.read(audioEncodeProvider.notifier).stopRecording()
                : () => ref.read(audioEncodeProvider.notifier).startRecording(),
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRecording ? AppTheme.accentCyan : accentColor.withValues(alpha: 0.1),
                  boxShadow: isRecording ? [
                    BoxShadow(
                      color: AppTheme.accentCyan.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 10,
                    )
                  ] : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      size: 64,
                      color: isRecording ? Colors.black : accentColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isRecording ? l10n.translate('stop_recording') : l10n.translate('start_recording'),
                      style: GoogleFonts.cairo(
                        color: isRecording ? Colors.black : accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 40),
        
        // Timer & Estimation
        Text(
          '$minutes:$seconds / $totalMinutes:$totalSeconds',
          style: GoogleFonts.outfit(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Live Chunk Estimator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.translate('expected_chunks'),
              style: TextStyle(
                color: isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                fontSize: 14,
              ),
            ),
            Text(
              state.estimatedChunks == 1 
                ? l10n.translate('message_count_1')
                : l10n.translate('message_count_2'),
              style: const TextStyle(
                color: AppTheme.successGreen,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 60),
        
        if (isRecording)
          TextButton.icon(
            onPressed: () => ref.read(audioEncodeProvider.notifier).cancelRecording(),
            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
            label: Text(
              l10n.translate('cancel_recording').toUpperCase(),
              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
            ),
          ),
      ],
    );
  }

  Widget _buildProcessingUI(Color accentColor, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: accentColor, strokeWidth: 2),
          const SizedBox(height: 24),
          Text(
            l10n.translate('processing').toUpperCase(),
            style: GoogleFonts.cairo(
              color: accentColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessUI(
    BuildContext context,
    WidgetRef ref,
    AudioEncodeState state,
    AppLocalizations l10n,
    ThemeData theme,
    Color accentColor,
    bool isDark,
  ) {
    return SuccessReveal(
      child: Column(
        children: [
          const Icon(Icons.check_circle_rounded, size: 48, color: AppTheme.successGreen),
          const SizedBox(height: 12),
          Text(
            l10n.translate('complete'),
            style: GoogleFonts.cairo(
              color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 20),
          
          // Audio Preview Player
          _AudioPreviewPlayer(audioBytes: state.audioBytes!, accentColor: accentColor, isDark: isDark),
          
          const SizedBox(height: 16),
          
          // Performance Metrics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                label: l10n.translate('conversion_time'),
                value: '${state.processingDurationMs}ms',
                icon: Icons.timer_outlined,
                accentColor: accentColor,
              ),
              _StatItem(
                label: l10n.translate('total_chars'),
                value: state.totalCharacters.toString(),
                icon: Icons.text_fields_rounded,
                accentColor: accentColor,
              ),
            ],
          ),

          const SizedBox(height: 20),
          
          Expanded(
            child: ListView.separated(
              itemCount: state.chunks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _AudioChunkCard(
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
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;

  const _StatItem({required this.label, required this.value, required this.icon, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 16, color: accentColor.withValues(alpha: 0.7)),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14, color: accentColor),
        ),
        Text(
          label.toUpperCase(),
          style: TextStyle(fontSize: 10, color: Colors.grey.withValues(alpha: 0.8), letterSpacing: 1),
        ),
      ],
    );
  }
}

class _WaveVisualizer extends StatelessWidget {
  final double amplitude;
  final Color color;

  const _WaveVisualizer({required this.amplitude, required this.color});

  @override
  Widget build(BuildContext context) {
    // Sanitize amplitude to prevent NaN/Infinity Layout Exceptions
    double safeAmplitude = amplitude;
    if (safeAmplitude.isNaN || safeAmplitude.isInfinite) {
      safeAmplitude = -160.0;
    }
    double normalized = (safeAmplitude + 160.0) / 160.0;
    if (normalized < 0.0) normalized = 0.0;
    if (normalized > 1.0) normalized = 1.0;
    
    final double scale = 1.0 + (normalized * 0.8);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: scale),
      duration: const Duration(milliseconds: 100),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 160 * value,
              height: 160 * value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: 0.1 * normalized),
              ),
            ),
            Container(
              width: 180 * (value * 0.9),
              height: 180 * (value * 0.9),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.2 * normalized), width: 2),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AudioPreviewPlayer extends StatefulWidget {
  final Uint8List audioBytes;
  final Color accentColor;
  final bool isDark;

  const _AudioPreviewPlayer({required this.audioBytes, required this.accentColor, required this.isDark});

  @override
  State<_AudioPreviewPlayer> createState() => _AudioPreviewPlayerState();
}

class _AudioPreviewPlayerState extends State<_AudioPreviewPlayer> {
  late AudioPlayer _player;
  bool _isPlaying = false;
  String? _tempPath;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      final tempDir = await getTemporaryDirectory();
      _tempPath = '${tempDir.path}/hams_preview_${DateTime.now().millisecondsSinceEpoch}.ogg';
      final file = File(_tempPath!);
      await file.writeAsBytes(widget.audioBytes);

      await _player.setAudioSource(AudioSource.file(_tempPath!));
      
      _player.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
            if (state.processingState == ProcessingState.completed) {
              _isPlaying = false;
              _player.seek(Duration.zero);
              _player.pause();
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Audio Player Init Error: $e');
    }
  }

  @override
  void dispose() {
    _player.dispose();
    if (_tempPath != null) {
      try {
        File(_tempPath!).delete();
      } catch (_) {}
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return StyleCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_isPlaying) {
                _player.pause();
              } else {
                _player.play();
              }
            },
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
              color: widget.accentColor,
              size: 48,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate('preview_audio'),
                style: GoogleFonts.cairo(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: widget.isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
                ),
              ),
              StreamBuilder<Duration>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  final duration = _player.duration ?? Duration.zero;
                  return Text(
                    '${_formatDuration(position)} / ${_formatDuration(duration)}',
                    style: TextStyle(
                      fontFamily: 'Monospace',
                      fontSize: 12,
                      color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final String minutes = d.inMinutes.toString().padLeft(2, '0');
    final String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _AudioChunkCard extends StatefulWidget {
  final int index;
  final int total;
  final String content;
  final Color accentColor;
  final bool isDark;

  const _AudioChunkCard({required this.index, required this.total, required this.content, required this.accentColor, required this.isDark});

  @override
  State<_AudioChunkCard> createState() => _AudioChunkCardState();
}

class _AudioChunkCardState extends State<_AudioChunkCard> {
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
    final l10n = AppLocalizations.of(context);
    final preview = widget.content.length > 30 ? '${widget.content.substring(0, 30)}...' : widget.content;

    return StyleCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GDA:${widget.index}/${widget.total}',
                  style: TextStyle(color: widget.accentColor, fontWeight: FontWeight.bold, fontSize: 10, fontFamily: 'Monospace'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  preview,
                  style: TextStyle(color: widget.isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondaryLight, fontSize: 10, fontFamily: 'Monospace'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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

// _MyBytesSource removed in favor of file-based source
