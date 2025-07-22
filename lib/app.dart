import 'package:flutter/material.dart';
import 'screens/deleted_screen.dart';
import 'screens/sort_later_screen.dart';
import 'core/app_routes.dart';
import 'models/photo_action.dart';
import 'screens/splash_screen.dart';
import 'core/theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Stats')),
    body: const Center(child: Text('Stats coming soon')),
  );
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Settings')),
    body: const Center(child: Text('Settings coming soon')),
  );
}

class PicSorApp extends StatelessWidget {
  const PicSorApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PicSor',
    themeMode: ThemeMode.system,
    theme: appTheme,
    darkTheme: appDarkTheme,
    home: const SplashScreen(),
    routes: {
      // Do not include '/' route since home is set
      AppRoutes.deleted: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as List<PhotoAction>?;
        return DeletedScreen(actions: args ?? const []);
      },
      AppRoutes.sortLater: (context) {
        final args =
            ModalRoute.of(context)?.settings.arguments as List<PhotoAction>?;
        return SortLaterScreen(actions: args ?? const []);
      },
      AppRoutes.stats: (context) => const StatsScreen(),
      AppRoutes.settings: (context) => const SettingsScreen(),
    },
  );
}
