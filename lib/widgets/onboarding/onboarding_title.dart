import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OnboardingTitle extends StatelessWidget {
  final String text;
  const OnboardingTitle({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.headline(context),
      textAlign: TextAlign.center,
    );
  }
}
