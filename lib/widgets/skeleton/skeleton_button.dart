import 'package:flutter/material.dart';

class SkeletonButton extends StatefulWidget {
  final double size;
  final double borderRadius;

  const SkeletonButton({super.key, this.size = 48, this.borderRadius = 24});

  @override
  State<SkeletonButton> createState() => _SkeletonButtonState();
}

class _SkeletonButtonState extends State<SkeletonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            color: _getSkeletonColor(context),
          ),
        );
      },
    );
  }

  Color _getSkeletonColor(BuildContext context) {
    final baseColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.grey[300]!
            : Colors.grey[700]!;

    final shimmerColor =
        Theme.of(context).brightness == Brightness.light
            ? Colors.grey[100]!
            : Colors.grey[600]!;

    return Color.lerp(baseColor, shimmerColor, _animation.value)!;
  }
}
