import 'package:flutter/material.dart';
import '../core/theme.dart';

class FloatingLiveLabel extends StatelessWidget {
  final String label;
  final Color color;
  final Alignment alignment;
  final EdgeInsets padding;
  final bool visible;

  const FloatingLiveLabel({
    Key? key,
    required this.label,
    required this.color,
    required this.alignment,
    this.padding = EdgeInsets.zero,
    this.visible = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: AnimatedOpacity(
        opacity: visible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 120),
        child: Padding(
          padding: padding,
          child: Text(
            label,
            style: AppTextStyles.headline(context).copyWith(
              color: color,
              fontSize: Scale.of(context, 36),
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              shadows: [
                Shadow(
                  blurRadius: 24,
                  color: color.withOpacity(0.8),
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
