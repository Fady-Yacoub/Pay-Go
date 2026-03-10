import 'dart:async';
import 'package:flutter/material.dart';

enum FadeDirection { top, bottom, left, right, none }

class FadeInAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  final FadeDirection direction;
  final double slideOffset;
  final bool enableScale;
  final double initialScale;
  final Duration duration;

  const FadeInAnimation({
    super.key,
    required this.child,
    this.delay = 0,
    this.direction = FadeDirection.bottom,
    this.slideOffset = 25.0, // تقليل بسيط للمسافة بيدي إحساس بالسرعة
    this.enableScale = true,
    this.initialScale = 0.96, // تقريب القيمة من 1 بيقلل مجهود الـ GPU
    this.duration = const Duration(milliseconds: 500), // 500ms أسرع وأخف
  });

  @override
  State<FadeInAnimation> createState() => _FadeInAnimationState();
}

class _FadeInAnimationState extends State<FadeInAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<Offset> _slide;
  late Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    // استخدام Curves.decelerate بيدي إحساس إن الحاجة "بترسى" مكانها بنعومة
    _opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeIn)),
    );

    _slide = Tween<Offset>(begin: _getDirectionOffset(), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _scale = Tween<double>(begin: widget.enableScale ? widget.initialScale : 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _startAnimation();
  }

  void _startAnimation() {
    if (widget.delay > 0) {
      _timer = Timer(Duration(milliseconds: widget.delay), () {
        if (mounted) _controller.forward();
      });
    } else {
      _controller.forward();
    }
  }

  Offset _getDirectionOffset() {
    const double factor = 0.15; // تقليل الـ Offset بيخلي الـ Transition يبان أسرع
    switch (widget.direction) {
      case FadeDirection.top: return const Offset(0, -factor);
      case FadeDirection.bottom: return const Offset(0, factor);
      case FadeDirection.left: return const Offset(-factor, 0);
      case FadeDirection.right: return const Offset(factor, 0);
      case FadeDirection.none: return Offset.zero;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 💡 إضافة RepaintBoundary: دي بتخلي الأنيميشن يترسم في طبقة منفصلة
    // فـ ميبطأش بقية الشاشة وأنت بتعمل Scroll أو بتتحرك.
    return RepaintBoundary(
      child: FadeTransition(
        opacity: _opacity,
        child: SlideTransition(
          position: _slide,
          child: ScaleTransition(
            scale: _scale,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}