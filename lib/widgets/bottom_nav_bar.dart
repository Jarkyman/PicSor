import 'package:flutter/material.dart';
import '../core/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = Scale.of(context, 28);
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Theme.of(context).colorScheme.primary,
      unselectedItemColor: Theme.of(
        context,
      ).colorScheme.onSurface.withValues(alpha: 0.7),
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.swipe, size: iconSize),
          label: 'Swipe',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.delete_outline, size: iconSize),
          label: 'Deleted',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.watch_later_outlined, size: iconSize),
          label: 'Sort Later',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.bar_chart, size: iconSize),
          label: 'Stats',
        ),
      ],
    );
  }
}
