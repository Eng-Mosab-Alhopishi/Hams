// ignore_for_file: experimental_member_use
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import '../../core/theme/app_theme.dart';
import '../../core/animations/scrolling_ticker.dart';
import '../../core/widgets/style_adaptor.dart';
import '../../services/clipboard_service.dart';
import '../../core/l10n/app_localizations.dart';
import '../../services/payload_manager.dart';
import '../../core/providers/common_providers.dart';
import '../settings/settings_provider.dart';
import 'decode_provider.dart';

class DecodeScreen extends ConsumerStatefulWidget {
  const DecodeScreen({super.key});

  @override
  ConsumerState<DecodeScreen> createState() => _DecodeScreenState();
}

class _DecodeScreenState extends ConsumerState<DecodeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late ClipboardService _clipboardService;
  StreamSubscription<String>? _clipboardSubscription;
  
  late AnimationController _pulseController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clipboardService = ref.read(clipboardServiceProvider);
      _checkClipboardWithFeedback(showFeedback: false);
      _clipboardService.startWatching();
      _clipboardSubscription = _clipboardService.onChunkDetected.listen((chunk) {
        ref.read(decodeProvider.notifier).addChunk(chunk);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clipboardSubscription?.cancel();
    _pulseController.dispose();
    _audioPlayer.dispose();
    _clipboardService.stopWatching();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardWithFeedback(showFeedback: false);
    }
  }

  Future<void> _checkClipboardWithFeedback({required bool showFeedback}) async {
    final status = await _clipboardService.checkManual();
    if (!mounted) return;
    
    if (showFeedback) {
      final l10n = AppLocalizations.of(context);
      if (status == AppClipboardStatus.empty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(l10n.translate('paste_hint')),
          backgroundColor: Colors.orange,
        ));
      } else if (status == AppClipboardStatus.invalid) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid or already processed GhostDrop message.'),
          backgroundColor: Colors.redAccent,
        ));
      }
    }
  }



  Future<void> _openPayload(PayloadManager pm) async {
    final payload = await ref.read(decodeProvider.notifier).decodePayload(pm);
    if (payload == null) return;
    
    _showFullscreenModal(payload);
  }

  void _showFullscreenModal(ReassembledPayload payload) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _PayloadViewerModal(payload: payload, audioPlayer: _audioPlayer),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(decodeProvider);
    final theme = ref.watch(settingsProvider).themeMode;
    final isDark = theme == ThemeMode.dark || theme == ThemeMode.system;
    final l10n = AppLocalizations.of(context);
    final Color accentColor = isDark ? AppTheme.accentPurple : AppTheme.accentLight;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Binary code effect in the background (only if payloads exist)
          if (state.payloads.isNotEmpty)
            ScrollingTicker(textColor: accentColor),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  _buildWatchingBanner(l10n, isDark),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(
                          Icons.arrow_back_ios_new_rounded, 
                          color: isDark ? AppTheme.accentCyan : AppTheme.accentLight,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.translate('decode_title'),
                          style: GoogleFonts.cairo(
                            color: isDark ? AppTheme.accentCyan : AppTheme.accentLight,
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      if (state.payloads.isNotEmpty)
                        InkWell(
                          onTap: () {
                             ref.read(decodeProvider.notifier).reset();
                             _clipboardService.clearProcessed();
                             HapticFeedback.lightImpact();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.redAccent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.delete_sweep_rounded, color: Colors.redAccent, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.translate('clear_all').toUpperCase(),
                                  style: GoogleFonts.cairo(
                                    color: Colors.redAccent,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 9,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _ManualInputArea(
                    isDark: isDark,
                    accentColor: accentColor,
                    onAdd: (text) {
                      ref.read(decodeProvider.notifier).addChunk(text);
                    },
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: state.payloads.isEmpty 
                      ? Center(child: Text(l10n.translate('paste_hint'), style: GoogleFonts.cairo(color: Colors.grey)))
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: state.payloads.length,
                          itemBuilder: (context, index) {
                            final pm = state.payloads[index];
                            return _buildPayloadCard(pm, l10n, isDark);
                          },
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

  Widget _buildWatchingBanner(AppLocalizations l10n, bool isDark) {
    final bannerColor = isDark ? AppTheme.accentCyan : AppTheme.accentLight;
    return FadeTransition(
      opacity: CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: bannerColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: bannerColor, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Text(
              l10n.translate('watching_clipboard').toUpperCase(),
              style: TextStyle(
                color: bannerColor, 
                fontSize: 9, 
                fontWeight: FontWeight.w900, 
                letterSpacing: 1.5,
                fontFamily: GoogleFonts.cairo().fontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildPayloadCard(PayloadManager pm, AppLocalizations l10n, bool isDark) {
    final bool isReady = pm.receivedCount == pm.totalChunks;
    final bool isAudio = pm.type == PayloadType.audio;
    final Color cardColor = isReady 
        ? (isDark ? AppTheme.successGreen : const Color(0xFF2E7D32)) // Stronger green for light mode
        : (isDark ? Colors.orange.shade400 : Colors.orange.shade900);
    final IconData statusIcon = isReady ? Icons.check_circle_rounded : Icons.hourglass_top_rounded;
    final IconData typeIcon = isAudio ? Icons.graphic_eq_rounded : Icons.image_rounded;
    final String typeName = isAudio ? l10n.translate('audio') : l10n.translate('encode');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF1A1A1A) // Solid dark gray (No transparency)
            : Colors.white,           // Solid white (No transparency)
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardColor.withValues(alpha: 0.6), 
          width: 2.0 // Thicker border
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.black.withValues(alpha: 0.1)),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Visual Progress Fill Layer
          if (!isReady)
            Positioned.fill(
              child: FractionallySizedBox(
                alignment: l10n.locale.languageCode == 'ar' ? Alignment.centerRight : Alignment.centerLeft,
                widthFactor: pm.totalChunks > 0 ? pm.receivedCount / pm.totalChunks : 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                  decoration: BoxDecoration(
                    color: cardColor.withValues(alpha: isDark ? 0.15 : 0.1),
                  ),
                ),
              ),
            ),
          
          // Content Layer
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardColor.withValues(alpha: isReady ? 0.2 : 0.1), 
                        shape: BoxShape.circle
                      ),
                      child: Icon(typeIcon, color: cardColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                typeName.toUpperCase(),
                                style: GoogleFonts.cairo(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(statusIcon, color: cardColor, size: 14),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isReady 
                              ? l10n.translate('clipboard_ready')
                              : '${l10n.translate('clipboard_incomplete')} (${pm.receivedCount}/${pm.totalChunks})',
                            style: GoogleFonts.cairo(
                              color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black.withValues(alpha: 0.7),
                              fontSize: 12,
                              fontWeight: isReady ? FontWeight.normal : FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {
                      ref.read(decodeProvider.notifier).removePayload(pm);
                    }, icon: Icon(Icons.close, color: isDark ? Colors.white30 : Colors.black38)),
                  ],
                ),
          if (!isReady) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: pm.totalChunks > 0 ? pm.receivedCount / pm.totalChunks : 0,
                backgroundColor: cardColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(cardColor),
                minHeight: 6,
              ),
            ),
          ],
                if (isReady) ...[
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _openPayload(pm),
                    icon: const Icon(Icons.lock_open_rounded, size: 20),
                    label: Text(
                      l10n.translate('open_payload').toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardColor,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayloadViewerModal extends StatefulWidget {
  final ReassembledPayload payload;
  final AudioPlayer audioPlayer;

  const _PayloadViewerModal({required this.payload, required this.audioPlayer});

  @override
  State<_PayloadViewerModal> createState() => _PayloadViewerModalState();
}

class _PayloadViewerModalState extends State<_PayloadViewerModal> {
  bool _isPlaying = false;
  String? _audioFilePath;

  @override
  void initState() {
    super.initState();
    if (widget.payload.type == PayloadType.audio) {
      _initAudio();
    }
  }

  Future<void> _initAudio() async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/temp_decode_${DateTime.now().millisecondsSinceEpoch}.m4a');
    await file.writeAsBytes(widget.payload.bytes);
    _audioFilePath = file.path;
    await widget.audioPlayer.setFilePath(_audioFilePath!);
    
    widget.audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing && state.processingState != ProcessingState.completed;
        });
      }
    });
  }

  void _togglePlay() {
    if (_isPlaying) {
      widget.audioPlayer.pause();
    } else {
      if (widget.audioPlayer.processingState == ProcessingState.completed) {
        widget.audioPlayer.seek(Duration.zero);
      }
      widget.audioPlayer.play();
    }
  }

  bool _isSaved = false;

  Future<void> _saveImage() async {
    if (_isSaved) return;
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/ghostdrop_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(widget.payload.bytes);
      await Gal.putImage(file.path);
      if (mounted) {
        setState(() => _isSaved = true);
        HapticFeedback.mediumImpact();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _isSaved = false);
        });
      }
    } catch (_) {}
  }

  Future<void> _shareFile() async {
    final tempDir = await getTemporaryDirectory();
    final ext = widget.payload.type == PayloadType.audio ? 'm4a' : 'jpg';
    final file = File('${tempDir.path}/shared_file.$ext');
    await file.writeAsBytes(widget.payload.bytes);
    Share.shareXFiles([XFile(file.path)], text: 'Shared from GhostDrop');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color modalBg = isDark ? Colors.black.withValues(alpha: 0.75) : Colors.white.withValues(alpha: 0.85);
    final Color textColor = isDark ? Colors.white : Colors.black87;
    final Color secondaryTextColor = isDark ? Colors.white60 : Colors.black54;

    return ClipRRect(
      borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: modalBg,
            border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1), width: 1.5),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40, 
                height: 5, 
                decoration: BoxDecoration(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.2), 
                  borderRadius: BorderRadius.circular(10)
                )
              ),
              const SizedBox(height: 20),
              Expanded(
                child: widget.payload.type == PayloadType.image
                    ? InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Image.memory(widget.payload.bytes, fit: BoxFit.contain),
                      )
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isPlaying 
                                    ? AppTheme.accentPurple.withValues(alpha: 0.15)
                                    : Colors.transparent,
                                  boxShadow: _isPlaying 
                                    ? [BoxShadow(color: AppTheme.accentPurple.withValues(alpha: 0.3), blurRadius: 50, spreadRadius: 10)]
                                    : [],
                                ),
                                child: const Icon(Icons.graphic_eq_rounded, size: 80, color: AppTheme.accentPurple),
                              ),
                              const SizedBox(height: 40),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                                child: StreamBuilder<Duration>(
                                  stream: widget.audioPlayer.positionStream,
                                  builder: (context, snapshot) {
                                    final position = snapshot.data ?? Duration.zero;
                                    final duration = widget.audioPlayer.duration ?? Duration.zero;
                                    return Column(
                                      children: [
                                        SliderTheme(
                                          data: SliderThemeData(
                                            trackHeight: 6,
                                            activeTrackColor: AppTheme.accentPurple,
                                            inactiveTrackColor: AppTheme.accentPurple.withValues(alpha: 0.2),
                                            thumbColor: AppTheme.accentPurple,
                                            overlayColor: AppTheme.accentPurple.withValues(alpha: 0.2),
                                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                          ),
                                          child: Slider(
                                            value: position.inMilliseconds.toDouble().clamp(0.0, duration.inMilliseconds.toDouble() > 0 ? duration.inMilliseconds.toDouble() : 1.0),
                                            min: 0.0,
                                            max: duration.inMilliseconds > 0 ? duration.inMilliseconds.toDouble() : 1.0,
                                            onChanged: (val) {
                                              widget.audioPlayer.seek(Duration(milliseconds: val.toInt()));
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(_formatDuration(position), style: TextStyle(color: secondaryTextColor, fontFamily: 'Monospace', fontSize: 12)),
                                              Text(_formatDuration(duration), style: TextStyle(color: secondaryTextColor, fontFamily: 'Monospace', fontSize: 12)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 30),
                              GestureDetector(
                                onTap: _audioFilePath == null ? null : _togglePlay,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 70,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppTheme.accentPurple,
                                    border: Border.all(color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1), width: 2),
                                  ),
                                  child: Icon(
                                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: isDark ? Colors.black : Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (widget.payload.type == PayloadType.image)
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: _isSaved
                          ? Column(
                              key: const ValueKey('saved'),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 32),
                                const SizedBox(height: 4),
                                Text(AppLocalizations.of(context).translate('complete'), style: GoogleFonts.cairo(color: AppTheme.successGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : IconButton(
                              key: const ValueKey('save'),
                              onPressed: _saveImage,
                              icon: Icon(Icons.download_rounded, color: textColor, size: 32),
                            ),
                      ),
                    IconButton(
                      onPressed: _shareFile,
                      icon: Icon(Icons.share_rounded, color: textColor, size: 32),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ManualInputArea extends StatefulWidget {
  final bool isDark;
  final Color accentColor;
  final Function(String) onAdd;

  const _ManualInputArea({
    required this.isDark,
    required this.accentColor,
    required this.onAdd,
  });

  @override
  State<_ManualInputArea> createState() => _ManualInputAreaState();
}

class _ManualInputAreaState extends State<_ManualInputArea> {
  bool _isExpanded = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: SizeTransition(sizeFactor: anim, child: child),
      ),
      child: _isExpanded 
        ? _buildExpanded(l10n) 
        : _buildCollapsed(l10n),
    );
  }

  Widget _buildCollapsed(AppLocalizations l10n) {
    return StyleCard(
      key: const ValueKey('collapsed'),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = true),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.paste_rounded, color: widget.accentColor, size: 20),
              const SizedBox(width: 12),
              Text(
                l10n.translate('manual_paste'),
                style: GoogleFonts.cairo(
                  color: widget.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpanded(AppLocalizations l10n) {
    return StyleCard(
      key: const ValueKey('expanded'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.edit_note_rounded, color: widget.accentColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  l10n.translate('manual_paste'),
                  style: GoogleFonts.cairo(
                    color: widget.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => setState(() => _isExpanded = false),
                  icon: const Icon(Icons.close_rounded, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              style: TextStyle(color: widget.isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight),
              autofocus: true,
              decoration: InputDecoration(
                hintText: l10n.translate('paste_hint'),
                hintStyle: TextStyle(color: widget.isDark ? Colors.white30 : Colors.black38),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.accentColor.withValues(alpha: 0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.accentColor.withValues(alpha: 0.1)),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
                filled: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final text = _controller.text.trim();
                  if (text.isNotEmpty) {
                    widget.onAdd(text);
                    _controller.clear();
                    setState(() => _isExpanded = false);
                    HapticFeedback.mediumImpact();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  foregroundColor: widget.isDark ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: Text(
                  l10n.translate('convert'),
                  style: GoogleFonts.cairo(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
