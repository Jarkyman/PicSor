import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OnboardingButtonRow extends StatelessWidget {
  final List<Widget> buttons;
  const OnboardingButtonRow({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ...buttons.map(
          (b) => Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: b,
            ),
          ),
        ),
      ],
    );
  }
}
