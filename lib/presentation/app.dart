import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flashforge/config/app_config.dart';
import 'package:flashforge/data/providers/providers.dart';
import 'package:flashforge/l10n/app_localizations.dart';
import 'package:flashforge/presentation/screens/language_settings_screen.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';
import 'package:flashforge/presentation/routes/app_router.dart';

/// Main application widget
class FlashForgeApp extends ConsumerWidget {
  /// Default constructor
  const FlashForgeApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch for theme changes
    final themeMode = ref.watch(themeModeProvider);
    
    // Watch for auth state changes
    final authState = ref.watch(authStateProvider);
    
    // Watch for locale changes
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'FlashForge',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: authState.maybeWhen(
        data: (isAuthenticated) => isAuthenticated 
            ? AppRouter.homeRoute 
            : AppRouter.splashRoute,
        orElse: () => AppRouter.splashRoute,
      ),
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
