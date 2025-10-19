import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

final loginAnimationProvider =
ChangeNotifierProvider<AnimationNotifier>((ref) {
  return AnimationNotifier();
});

class AnimationNotifier extends ChangeNotifier {
  late final AnimationController _controller;
  late final Animation<AlignmentGeometry> animation;
  bool _initialized = false;

  void initAnimation(TickerProvider vsync) {
    if (_initialized) return;

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: vsync,
    )..repeat(reverse: true);

    animation = Tween<AlignmentGeometry>(
      begin: Alignment.bottomRight,
      end: Alignment.center,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.decelerate),
    );

    _initialized = true;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
