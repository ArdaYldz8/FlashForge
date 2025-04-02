import 'package:flutter/material.dart';
import 'package:flashforge/presentation/screens/splash_screen.dart';
import 'package:flashforge/presentation/screens/onboarding_screen.dart';
import 'package:flashforge/presentation/screens/home_screen.dart';
import 'package:flashforge/presentation/screens/create_flashcard_screen.dart';
import 'package:flashforge/presentation/screens/create_flashcard_from_file_screen.dart';
import 'package:flashforge/presentation/screens/study_screen.dart';
import 'package:flashforge/presentation/screens/deck_detail_screen.dart';
import 'package:flashforge/presentation/screens/settings_screen.dart';
import 'package:flashforge/presentation/screens/profile_screen.dart';
import 'package:flashforge/presentation/screens/language_settings_screen.dart';
import 'package:flashforge/presentation/screens/auth/login_screen.dart';
import 'package:flashforge/presentation/screens/auth/signup_screen.dart';
import 'package:flashforge/utils/analytics_service.dart';

/// App navigation routes
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();
  
  // Route names
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String homeRoute = '/home';
  static const String createFlashcardRoute = '/create-flashcard';
  static const String createFlashcardFromFileRoute = '/create-flashcard-from-file';
  static const String studyRoute = '/study';
  static const String deckDetailRoute = '/deck-detail';
  static const String settingsRoute = '/settings';
  static const String profileRoute = '/profile';
  static const String languageSettingsRoute = '/language-settings';
  static const String loginRoute = '/login';
  static const String signupRoute = '/signup';
  
  // Initial route
  static const String initialRoute = splashRoute;
  
  /// Route generator
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splashRoute:
        AnalyticsService.logScreenView('splash');
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      
      case onboardingRoute:
        AnalyticsService.logScreenView('onboarding');
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      
      case homeRoute:
        AnalyticsService.logScreenView('home');
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      
      case createFlashcardRoute:
        AnalyticsService.logScreenView('create_flashcard');
        return MaterialPageRoute(builder: (_) => const CreateFlashcardScreen());
        
      case createFlashcardFromFileRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        AnalyticsService.logScreenView('create_flashcard_from_file');
        return MaterialPageRoute(
          builder: (_) => CreateFlashcardFromFileScreen(
            deckId: args?['deckId'] ?? '',
          ),
        );
      
      case studyRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        AnalyticsService.logScreenView('study');
        return MaterialPageRoute(
          builder: (_) => StudyScreen(
            deckId: args?['deckId'] as String? ?? '',
          ),
        );
      
      case deckDetailRoute:
        final args = settings.arguments as Map<String, dynamic>?;
        AnalyticsService.logScreenView('deck_detail');
        return MaterialPageRoute(
          builder: (_) => DeckDetailScreen(
            deckId: args?['deckId'] as String? ?? '',
          ),
        );
      
      case settingsRoute:
        AnalyticsService.logScreenView('settings');
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
        
      case languageSettingsRoute:
        AnalyticsService.logScreenView('language_settings');
        return MaterialPageRoute(builder: (_) => const LanguageSettingsScreen());
      
      case profileRoute:
        AnalyticsService.logScreenView('profile');
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      
      case loginRoute:
        AnalyticsService.logScreenView('login');
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      
      case signupRoute:
        AnalyticsService.logScreenView('signup');
        return MaterialPageRoute(builder: (_) => const SignupScreen());
        
      default:
        // If the route is not recognized, navigate to splash screen
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
