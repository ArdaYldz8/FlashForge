import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

/// Application-wide configuration and initialization
class AppConfig {
  /// Private constructor to prevent instantiation
  AppConfig._();
  
  /// Whether the app is in development mode
  static bool get isDevelopment => kDebugMode;
  
  /// Hugging Face API base URL
  static const String huggingFaceApiBaseUrl = 'https://api-inference.huggingface.co/models';
  
  /// Initialize all required services for the app
  static Future<void> initialize() async {
    // Initialize Hive for local storage
    await Hive.initFlutter();
    
    // Register Hive adapters here
    // Hive.registerAdapter(FlashcardAdapter());
    // Hive.registerAdapter(DeckAdapter());
    
    // Open Hive boxes
    await Hive.openBox('settings');
    await Hive.openBox('userPreferences');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Initialize other services here
  }
  
  /// Get the Hugging Face API token
  /// In production, this should be securely stored
  static String? get huggingFaceApiToken {
    // For development, return a placeholder
    if (isDevelopment) {
      return 'YOUR_HUGGING_FACE_API_TOKEN';
    }
    
    // In production, retrieve from secure storage
    final box = Hive.box('settings');
    return box.get('huggingFaceApiToken');
  }
  
  /// Set the Hugging Face API token
  static Future<void> setHuggingFaceApiToken(String token) async {
    final box = Hive.box('settings');
    await box.put('huggingFaceApiToken', token);
  }
  
  /// Get the supported languages
  static List<String> get supportedLanguages {
    return [
      'en', // English
      'es', // Spanish
      'tr', // Turkish
    ];
  }

  /// Get the display name for a language code
  static String getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Spanish';
      case 'tr':
        return 'Turkish';
      default:
        return 'Unknown';
    }
  }

  /// Get the user's preferred language code
  static String get preferredLanguage {
    final box = Hive.box('userPreferences');
    return box.get('languageCode', defaultValue: 'en');
  }

  /// Set the user's preferred language code
  static Future<void> setPreferredLanguage(String languageCode) async {
    final box = Hive.box('userPreferences');
    await box.put('languageCode', languageCode);
  }

  /// Get the theme mode (light/dark/system)
  static String get themeMode {
    final box = Hive.box('userPreferences');
    return box.get('themeMode', defaultValue: 'system');
  }

  /// Set the theme mode (light/dark/system)
  static Future<void> setThemeMode(String theme) async {
    final box = Hive.box('userPreferences');
    await box.put('themeMode', theme);
  }
}
