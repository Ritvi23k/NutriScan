// =============================================================================
// widgets/animated_list_item.dart
// =============================================================================
// A reusable widget that provides staggered slide + fade entrance animations
// for list items. Used throughout the app for premium list transitions.
// =============================================================================

import 'package:flutter/material.dart';

/// Animates a child widget with a slide-up + fade-in effect.
///
/// Use [index] to stagger the animation timing across multiple list items.
/// Each subsequent item will start its animation slightly later, creating
/// a cascading entrance effect.
class AnimatedListItem extends StatefulWidget {
  /// The child widget to animate.
  final Widget child;

  /// The index of this item in the list (used for stagger delay).
  final int index;

  /// Base duration of the animation.
  final Duration duration;

  /// Direction of the slide. Positive = from below, negative = from above.
  final double slideOffset;

  /// Maximum stagger delay multiplier per item.
  final int staggerDelayMs;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
    this.duration = const Duration(milliseconds: 500),
    this.slideOffset = 30.0,
    this.staggerDelayMs = 80,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    // Stagger the start based on index (cap to avoid excessive delays).
    final delay = (widget.index.clamp(0, 10)) * widget.staggerDelayMs;
    Future.delayed(
      Duration(milliseconds: delay),
      () {
        if (mounted) _controller.forward();
      },
    );
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
        return Transform.translate(
          offset: _slideAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
