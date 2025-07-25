import 'package:flutter/material.dart';

class SkeletonCard extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const SkeletonCard({
    super.key,
    this.width = double.infinity,
    this.height = 400,
    this.borderRadius = 20,
  });

  @override
  State<SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
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
          width: widget.width,
          height: widget.height,
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
