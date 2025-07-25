import 'package:flutter/material.dart';
import '../../core/theme.dart';

class OnboardingBody extends StatelessWidget {
  final String text;
  final bool scrollable;
  const OnboardingBody({
    super.key,
    required this.text,
    this.scrollable = false,
  });

  @override
  Widget build(BuildContext context) {
    final body = Text(
      text,
      style: AppTextStyles.body(context),
      textAlign: TextAlign.center,
    );
    if (scrollable) {
      return Expanded(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: body,
        ),
      );
    } else {
      return body;
    }
  }
}
