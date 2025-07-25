import 'package:flutter/material.dart';
import '../core/theme.dart';

class TimeCheatDialog extends StatelessWidget {
  const TimeCheatDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Time Manipulation Detected',
        style: AppTextStyles.title(context),
      ),
      content: Text(
        'Device time appears to have been set backwards. Swiping is blocked. Please correct your system time.',
        style: AppTextStyles.body(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK', style: AppTextStyles.button(context)),
        ),
      ],
    );
  }
}

Future<void> showTimeCheatDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const TimeCheatDialog(),
  );
}
