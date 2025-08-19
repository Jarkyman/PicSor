import 'package:flutter/material.dart';
import '../../core/theme.dart';

class SelectionSection extends StatelessWidget {
  final String title;
  final Widget child;

  const SelectionSection({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title(context).copyWith(
            fontWeight: FontWeight.w800,
            fontSize: Scale.of(context, 24),
            letterSpacing: -0.3,
          ),
        ),
        SizedBox(height: AppSpacing.lg),
        child,
      ],
    );
  }
}
