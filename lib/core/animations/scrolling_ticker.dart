import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScrollingTicker extends StatefulWidget {
  final Color textColor;
  const ScrollingTicker({super.key, this.textColor = AppTheme.accentCyan});

  @override
  State<ScrollingTicker> createState() => _ScrollingTickerState();
}

class _ScrollingTickerState extends State<ScrollingTicker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  final List<String> _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!#\$%&()*+,-./:;<=>?@[]^_`{|}~'.split('');
  // _data field removed

  @override
  void initState() {
    super.initState();
    // _data initialization removed
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.1,
          child: ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black, Colors.transparent],
              stops: [0.0, 0.5, 1.0],
            ).createShader(bounds),
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              controller: ScrollController(initialScrollOffset: _controller.value * 1000),
              itemCount: 100,
              itemBuilder: (context, index) {
                return Text(
                  List.generate(40, (i) => _chars[_random.nextInt(_chars.length)]).join(''),
                  style: TextStyle(
                    color: widget.textColor,
                    fontFamily: 'Monospace',
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
