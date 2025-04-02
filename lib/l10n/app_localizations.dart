import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_localizations_delegate.dart';

/// Class for handling app localizations
class AppLocalizations {
  /// Locale for the current instance
  final Locale locale;

  /// Constructor
  AppLocalizations(this.locale);

  /// Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Static delegate for app localizations
  static const LocalizationsDelegate<AppLocalizations> delegate =
      AppLocalizationsDelegate();

  /// Static list of supported locales
  static const List<Locale> supportedLocales = [
    Locale('en', ''), // English
    Locale('es', ''), // Spanish
    Locale('tr', ''), // Turkish
  ];

  /// Map of localized values for English
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Common
      'app_name': 'FlashForge',
      'done': 'Done',
      'cancel': 'Cancel',
      'save': 'Save',
      'edit': 'Edit',
      'delete': 'Delete',
      'create': 'Create',
      'search': 'Search',
      'settings': 'Settings',
      
      // Auth
      'login': 'Login',
      'signup': 'Sign Up',
      'logout': 'Logout',
      'email': 'Email',
      'password': 'Password',
      'confirm_password': 'Confirm Password',
      'forgot_password': 'Forgot Password?',
      'create_account': 'Create Account',
      'already_have_account': 'Already have an account? Log in',
      'dont_have_account': 'Don\'t have an account? Sign up',
      
      // Home
      'home': 'Home',
      'decks': 'Decks',
      'my_decks': 'My Decks',
      'recent_decks': 'Recent Decks',
      'popular_decks': 'Popular Decks',
      'view_all': 'View All',
      
      // Deck
      'deck': 'Deck',
      'create_deck': 'Create Deck',
      'edit_deck': 'Edit Deck',
      'delete_deck': 'Delete Deck',
      'deck_name': 'Deck Name',
      'deck_description': 'Deck Description',
      'cards': 'Cards',
      'card_count': 'Card Count',
      'progress': 'Progress',
      'mastered': 'Mastered',
      'public': 'Public',
      'private': 'Private',
      
      // Flashcard
      'flashcard': 'Flashcard',
      'flashcards': 'Flashcards',
      'create_flashcard': 'Create Flashcard',
      'edit_flashcard': 'Edit Flashcard',
      'delete_flashcard': 'Delete Flashcard',
      'question': 'Question',
      'answer': 'Answer',
      'front': 'Front',
      'back': 'Back',
      'hint': 'Hint',
      
      // Study
      'study': 'Study',
      'study_now': 'Study Now',
      'start_study': 'Start Study',
      'continue_study': 'Continue Study',
      'review': 'Review',
      'easy': 'Easy',
      'medium': 'Medium',
      'hard': 'Hard',
      'flip_card': 'Flip Card',
      'knew_it': 'Knew It',
      'almost': 'Almost',
      'didnt_know': 'Didn\'t Know',
      'study_complete': 'Study Complete',
      'study_stats': 'Study Statistics',
      
      // AI
      'generate_cards': 'Generate Cards',
      'generating': 'Generating...',
      'generated_success': 'Successfully generated cards',
      'extract_from_text': 'Extract from Text',
      'extract_from_url': 'Extract from URL',
      'extract_from_pdf': 'Extract from PDF',
      'extract_from_image': 'Extract from Image',
      'select_file': 'Select File',
      'choose_file': 'Choose File',
      'file_uploading': 'Uploading file...',
      'fileTooLarge': 'File too large. Maximum size is 10 MB.',
      'filePickerError': 'Error selecting file. Please try again.',
      'generate': 'Generate',
      
      // Profile
      'profile': 'Profile',
      'edit_profile': 'Edit Profile',
      'stats': 'Statistics',
      'achievements': 'Achievements',
      'history': 'History',
      'notifications': 'Notifications',
      'language': 'Language',
      'theme': 'Theme',
      'light_mode': 'Light Mode',
      'dark_mode': 'Dark Mode',
      'system_mode': 'System Default',
      
      // Errors
      'error': 'Error',
      'error_occurred': 'An error occurred',
      'try_again': 'Try Again',
      'no_internet': 'No internet connection',
      'no_decks': 'No decks found',
      'no_cards': 'No cards found',
      'invalid_email': 'Invalid email',
      'invalid_password': 'Invalid password',
      'password_mismatch': 'Passwords do not match',
    },
    'es': {
      // Common
      'app_name': 'FlashForge',
      'done': 'Hecho',
      'cancel': 'Cancelar',
      'save': 'Guardar',
      'edit': 'Editar',
      'delete': 'Eliminar',
      'create': 'Crear',
      'search': 'Buscar',
      'settings': 'Configuración',
      
      // Auth
      'login': 'Iniciar sesión',
      'signup': 'Registrarse',
      'logout': 'Cerrar sesión',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'confirm_password': 'Confirmar contraseña',
      'forgot_password': '¿Olvidaste tu contraseña?',
      'create_account': 'Crear cuenta',
      'already_have_account': '¿Ya tienes una cuenta? Inicia sesión',
      'dont_have_account': '¿No tienes una cuenta? Regístrate',
      
      // Home
      'home': 'Inicio',
      'decks': 'Mazos',
      'my_decks': 'Mis mazos',
      'recent_decks': 'Mazos recientes',
      'popular_decks': 'Mazos populares',
      'view_all': 'Ver todo',
      
      // Deck
      'deck': 'Mazo',
      'create_deck': 'Crear mazo',
      'edit_deck': 'Editar mazo',
      'delete_deck': 'Eliminar mazo',
      'deck_name': 'Nombre del mazo',
      'deck_description': 'Descripción del mazo',
      'cards': 'Tarjetas',
      'card_count': 'Número de tarjetas',
      'progress': 'Progreso',
      'mastered': 'Dominado',
      'public': 'Público',
      'private': 'Privado',
      
      // Additional Spanish translations would go here
    },
    'tr': {
      // Common
      'app_name': 'FlashForge',
      'done': 'Tamam',
      'cancel': 'İptal',
      'save': 'Kaydet',
      'edit': 'Düzenle',
      'delete': 'Sil',
      'create': 'Oluştur',
      'search': 'Ara',
      'settings': 'Ayarlar',
      
      // Auth
      'login': 'Giriş',
      'signup': 'Kaydol',
      'logout': 'Çıkış',
      'email': 'E-posta',
      'password': 'Şifre',
      'confirm_password': 'Şifreyi Onayla',
      'forgot_password': 'Şifreni mi unuttun?',
      'create_account': 'Hesap Oluştur',
      'already_have_account': 'Zaten hesabın var mı? Giriş yap',
      'dont_have_account': 'Hesabın yok mu? Kaydol',
      
      // Additional Turkish translations would go here
    },
  };

  /// Get localized string for a key
  String? translate(String key) {
    final languageCode = locale.languageCode;
    if (!_localizedValues.containsKey(languageCode)) {
      return _localizedValues['en']![key];
    }
    return _localizedValues[languageCode]![key] ?? _localizedValues['en']![key];
  }

  // Getters for common strings
  /// App name
  String get appName => translate('app_name')!;
  
  /// Done button text
  String get done => translate('done')!;
  
  /// Cancel button text
  String get cancel => translate('cancel')!;
  
  /// Save button text
  String get save => translate('save')!;
  
  /// Edit button text
  String get edit => translate('edit')!;
  
  /// Delete button text
  String get delete => translate('delete')!;
  
  /// Create button text
  String get create => translate('create')!;
  
  /// Search text
  String get search => translate('search')!;
  
  /// Settings text
  String get settings => translate('settings')!;
  
  /// Login text
  String get login => translate('login')!;
  
  /// Signup text
  String get signup => translate('signup')!;
  
  /// Home text
  String get home => translate('home')!;
  
  /// Study text
  String get study => translate('study')!;
  
  /// Profile text
  String get profile => translate('profile')!;
  
  /// Format date using the current locale
  String formatDate(DateTime date) {
    return DateFormat.yMMMd(locale.toString()).format(date);
  }
  
  /// Format time using the current locale
  String formatTime(DateTime time) {
    return DateFormat.Hm(locale.toString()).format(time);
  }
}
