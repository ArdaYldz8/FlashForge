import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for tracking app analytics
class AnalyticsService {
  /// Firebase analytics instance
  static final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Firebase analytics observer for navigation
  static FirebaseAnalyticsObserver get observer => 
      FirebaseAnalyticsObserver(analytics: _analytics);
      
  /// Log a generic custom event
  static Future<void> logEvent({
    required String eventName,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      _logConsole(eventName, parameters ?? {});
    } catch (e) {
      _logError('logEvent', e);
    }
  }

  /// Track screen view
  static Future<void> logScreenView(String screenName) async {
    try {
      await _analytics.logScreenView(screenName: screenName);
      _logConsole('Screen View', {'screen_name': screenName});
    } catch (e) {
      _logError('logScreenView', e);
    }
  }

  /// Track user login
  static Future<void> logLogin({String? method}) async {
    try {
      await _analytics.logLogin(loginMethod: method ?? 'email');
      _logConsole('Login', {'method': method ?? 'email'});
    } catch (e) {
      _logError('logLogin', e);
    }
  }

  /// Track user signup
  static Future<void> logSignUp({String? method}) async {
    try {
      await _analytics.logSignUp(signUpMethod: method ?? 'email');
      _logConsole('Sign Up', {'method': method ?? 'email'});
    } catch (e) {
      _logError('logSignUp', e);
    }
  }

  /// Track deck creation
  static Future<void> logDeckCreated({
    required String deckId,
    required String deckName,
    required int initialCardCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'deck_created',
        parameters: {
          'deck_id': deckId,
          'deck_name': deckName,
          'initial_card_count': initialCardCount,
        },
      );
      _logConsole('Deck Created', {
        'deck_id': deckId,
        'deck_name': deckName,
        'initial_card_count': initialCardCount,
      });
    } catch (e) {
      _logError('logDeckCreated', e);
    }
  }

  /// Track study activity
  static Future<void> logStudyActivity({
    required String activity,
    required String deckId,
    int? durationSeconds,
    int? cardsReviewed,
    int? cardsCorrect,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'study_activity',
        parameters: {
          'activity': activity,
          'deck_id': deckId,
          'duration_seconds': durationSeconds,
          'cards_reviewed': cardsReviewed,
          'cards_correct': cardsCorrect,
        },
      );
      _logConsole('Study Activity', {
        'activity': activity,
        'deck_id': deckId,
        'duration_seconds': durationSeconds,
        'cards_reviewed': cardsReviewed,
        'cards_correct': cardsCorrect,
      });
    } catch (e) {
      _logError('logStudyActivity', e);
    }
  }

  /// Track file upload
  static Future<void> logFileUpload({
    required String fileType,
    required int fileSize,
    required String purpose,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'file_upload',
        parameters: {
          'file_type': fileType,
          'file_size': fileSize,
          'purpose': purpose,
        },
      );
      _logConsole('File Upload', {
        'file_type': fileType,
        'file_size': fileSize,
        'purpose': purpose,
      });
    } catch (e) {
      _logError('logFileUpload', e);
    }
  }

  /// Track flashcard creation
  static Future<void> logFlashcardCreated({
    required String deckId,
    required String method,
    required int count,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'flashcard_created',
        parameters: {
          'deck_id': deckId,
          'method': method,
          'count': count,
        },
      );
      _logConsole('Flashcard Created', {
        'deck_id': deckId,
        'method': method,
        'count': count,
      });
    } catch (e) {
      _logError('logFlashcardCreated', e);
    }
  }

  /// Track study session started
  static Future<void> logStudySessionStarted({
    required String deckId,
    required String deckName,
    required int cardCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'study_session_started',
        parameters: {
          'deck_id': deckId,
          'deck_name': deckName,
          'card_count': cardCount,
        },
      );
      _logConsole('Study Session Started', {
        'deck_id': deckId,
        'deck_name': deckName,
        'card_count': cardCount,
      });
    } catch (e) {
      _logError('logStudySessionStarted', e);
    }
  }

  /// Track study session completed
  static Future<void> logStudySessionCompleted({
    required String deckId,
    required int totalCards,
    required int correctAnswers,
    required Duration duration,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'study_session_completed',
        parameters: {
          'deck_id': deckId,
          'total_cards': totalCards,
          'correct_answers': correctAnswers,
          'duration_seconds': duration.inSeconds,
          'accuracy_percentage': totalCards > 0 
              ? (correctAnswers / totalCards * 100).round() 
              : 0,
        },
      );
      _logConsole('Study Session Completed', {
        'deck_id': deckId,
        'total_cards': totalCards,
        'correct_answers': correctAnswers,
        'duration_seconds': duration.inSeconds,
      });
    } catch (e) {
      _logError('logStudySessionCompleted', e);
    }
  }

  /// Track language changed
  static Future<void> logLanguageChanged(String languageCode) async {
    try {
      await _analytics.logEvent(
        name: 'language_changed',
        parameters: {
          'language_code': languageCode,
        },
      );
      _logConsole('Language Changed', {'language_code': languageCode});
    } catch (e) {
      _logError('logLanguageChanged', e);
    }
  }

  /// Track theme changed
  static Future<void> logThemeChanged(String theme) async {
    try {
      await _analytics.logEvent(
        name: 'theme_changed',
        parameters: {
          'theme': theme,
        },
      );
      _logConsole('Theme Changed', {'theme': theme});
    } catch (e) {
      _logError('logThemeChanged', e);
    }
  }

  /// Track search performed
  static Future<void> logSearch(String query) async {
    try {
      await _analytics.logSearch(searchTerm: query);
      _logConsole('Search', {'query': query});
    } catch (e) {
      _logError('logSearch', e);
    }
  }

  /// Set user ID for analytics
  static Future<void> setUserId(String userId) async {
    try {
      await _analytics.setUserId(id: userId);
      _logConsole('Set User ID', {'user_id': userId});
    } catch (e) {
      _logError('setUserId', e);
    }
  }

  /// Set user properties
  static Future<void> setUserProperty({
    required String name,
    required String value,
  }) async {
    try {
      await _analytics.setUserProperty(name: name, value: value);
      _logConsole('Set User Property', {'name': name, 'value': value});
    } catch (e) {
      _logError('setUserProperty', e);
    }
  }

  /// Log error events
  static void _logError(String method, dynamic error) {
    if (kDebugMode) {
      print('Analytics Error in $method: $error');
    }
  }

  /// Log console events in debug mode
  static void _logConsole(String event, Map<String, dynamic> params) {
    if (kDebugMode) {
      print('Analytics Event: $event');
      print('Params: $params');
    }
  }
}
