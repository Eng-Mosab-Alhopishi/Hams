import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/l10n/app_localizations.dart';
import '../core/animations/premium_background.dart';
import '../features/settings/settings_provider.dart';
import 'router.dart';

class HamsApp extends ConsumerWidget {
  const HamsApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'Hams',
      // Localization
      locale: settings.locale,
      supportedLocales: const [
        Locale('en', ''),
        Locale('ar', ''),
      ],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      // Router
      routerConfig: goRouter,
      builder: (context, child) => PremiumBackground(child: child),
      debugShowCheckedModeBanner: false,
    );
  }
}
