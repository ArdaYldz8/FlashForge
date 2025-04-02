import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashforge/domain/models/learn_progress_model.dart';
import 'package:flashforge/domain/models/study_session_model.dart';
import 'package:flashforge/utils/analytics_service.dart';

/// Service for tracking user progress in learning
class ProgressTrackingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user ID
  String? get _userId => _auth.currentUser?.uid;

  /// Reference to user progress collection
  CollectionReference<Map<String, dynamic>> get _progressCollection =>
      _firestore.collection('user_progress');

  /// Reference to study sessions collection
  CollectionReference<Map<String, dynamic>> get _sessionsCollection =>
      _firestore.collection('study_sessions');

  /// Record a card review result
  Future<void> recordCardReview({
    required String deckId,
    required String cardId,
    required bool wasCorrect,
    required int confidenceLevel, // 1-5 where 5 is highest confidence
  }) async {
    if (_userId == null) return;

    try {
      final docRef = _progressCollection
          .doc(_userId)
          .collection('cards')
          .doc(cardId);

      // Get existing data or create new record
      final docSnapshot = await docRef.get();
      
      if (docSnapshot.exists) {
        // Update existing progress
        final data = docSnapshot.data()!;
        final totalReviews = (data['totalReviews'] ?? 0) + 1;
        final correctReviews = (data['correctReviews'] ?? 0) + (wasCorrect ? 1 : 0);
        final lastConfidence = confidenceLevel;
        
        // Calculate next review date based on spaced repetition algorithm
        final nextReviewDate = _calculateNextReviewDate(
          lastConfidence: confidenceLevel,
          consecutiveCorrect: wasCorrect ? (data['consecutiveCorrect'] ?? 0) + 1 : 0,
        );

        await docRef.update({
          'totalReviews': totalReviews,
          'correctReviews': correctReviews,
          'correctRate': correctReviews / totalReviews,
          'lastReviewDate': FieldValue.serverTimestamp(),
          'nextReviewDate': nextReviewDate,
          'lastConfidence': lastConfidence,
          'deckId': deckId,
          'consecutiveCorrect': wasCorrect 
              ? (data['consecutiveCorrect'] ?? 0) + 1 
              : 0,
        });
      } else {
        // Create new progress record
        final nextReviewDate = _calculateNextReviewDate(
          lastConfidence: confidenceLevel,
          consecutiveCorrect: wasCorrect ? 1 : 0,
        );

        await docRef.set({
          'cardId': cardId,
          'deckId': deckId,
          'totalReviews': 1,
          'correctReviews': wasCorrect ? 1 : 0,
          'correctRate': wasCorrect ? 1.0 : 0.0,
          'firstReviewDate': FieldValue.serverTimestamp(),
          'lastReviewDate': FieldValue.serverTimestamp(),
          'nextReviewDate': nextReviewDate,
          'lastConfidence': confidenceLevel,
          'consecutiveCorrect': wasCorrect ? 1 : 0,
        });
      }
    } catch (e) {
      print('Error recording card review: $e');
    }
  }

  /// Record a complete study session
  Future<void> recordStudySession({
    required String deckId,
    required int totalCards,
    required int correctAnswers,
    required Duration duration,
    Map<String, dynamic>? additionalData,
  }) async {
    if (_userId == null) return;

    try {
      // Create study session record
      final sessionData = {
        'userId': _userId,
        'deckId': deckId,
        'totalCards': totalCards,
        'correctAnswers': correctAnswers,
        'accuracyRate': totalCards > 0 ? correctAnswers / totalCards : 0,
        'durationSeconds': duration.inSeconds,
        'startTime': Timestamp.fromDate(
          DateTime.now().subtract(duration),
        ),
        'endTime': FieldValue.serverTimestamp(),
        ...?additionalData,
      };

      await _sessionsCollection.add(sessionData);

      // Update user's cumulative statistics
      final userStatsRef = _progressCollection.doc(_userId);
      final userStats = await userStatsRef.get();

      if (userStats.exists) {
        final data = userStats.data()!;
        final totalSessions = (data['totalSessions'] ?? 0) + 1;
        final totalCards = (data['totalCardsStudied'] ?? 0) + totalCards;
        final totalCorrect = (data['totalCorrectAnswers'] ?? 0) + correctAnswers;
        final totalTimeSeconds = (data['totalStudyTimeSeconds'] ?? 0) + duration.inSeconds;

        await userStatsRef.update({
          'totalSessions': totalSessions,
          'totalCardsStudied': totalCards,
          'totalCorrectAnswers': totalCorrect,
          'totalStudyTimeSeconds': totalTimeSeconds,
          'averageAccuracy': totalCards > 0 ? totalCorrect / totalCards : 0,
          'lastStudyDate': FieldValue.serverTimestamp(),
        });
      } else {
        await userStatsRef.set({
          'userId': _userId,
          'totalSessions': 1,
          'totalCardsStudied': totalCards,
          'totalCorrectAnswers': correctAnswers,
          'totalStudyTimeSeconds': duration.inSeconds,
          'averageAccuracy': totalCards > 0 ? correctAnswers / totalCards : 0,
          'firstStudyDate': FieldValue.serverTimestamp(),
          'lastStudyDate': FieldValue.serverTimestamp(),
        });
      }

      // Track analytics
      await AnalyticsService.logStudySessionCompleted(
        deckId: deckId,
        totalCards: totalCards,
        correctAnswers: correctAnswers,
        duration: duration,
      );
    } catch (e) {
      print('Error recording study session: $e');
    }
  }

  /// Get study statistics for a user
  Future<Map<String, dynamic>> getUserStatistics() async {
    if (_userId == null) {
      return {
        'totalSessions': 0,
        'totalCardsStudied': 0,
        'totalCorrectAnswers': 0,
        'averageAccuracy': 0.0,
        'totalStudyTimeSeconds': 0,
        'streakDays': 0,
      };
    }

    try {
      final userStatsRef = _progressCollection.doc(_userId);
      final userStats = await userStatsRef.get();

      if (userStats.exists) {
        final data = userStats.data()!;
        
        // Calculate streak days
        final streakDays = await _calculateStreakDays();
        
        return {
          'totalSessions': data['totalSessions'] ?? 0,
          'totalCardsStudied': data['totalCardsStudied'] ?? 0,
          'totalCorrectAnswers': data['totalCorrectAnswers'] ?? 0,
          'averageAccuracy': data['averageAccuracy'] ?? 0.0,
          'totalStudyTimeSeconds': data['totalStudyTimeSeconds'] ?? 0,
          'streakDays': streakDays,
        };
      } else {
        return {
          'totalSessions': 0,
          'totalCardsStudied': 0,
          'totalCorrectAnswers': 0,
          'averageAccuracy': 0.0,
          'totalStudyTimeSeconds': 0,
          'streakDays': 0,
        };
      }
    } catch (e) {
      print('Error getting user statistics: $e');
      return {
        'totalSessions': 0,
        'totalCardsStudied': 0,
        'totalCorrectAnswers': 0,
        'averageAccuracy': 0.0,
        'totalStudyTimeSeconds': 0,
        'streakDays': 0,
      };
    }
  }

  /// Get cards due for review
  Future<List<String>> getDueCards({
    required String deckId,
    int limit = 20,
  }) async {
    if (_userId == null) return [];

    try {
      final now = DateTime.now();
      final cardsRef = _progressCollection
          .doc(_userId)
          .collection('cards')
          .where('deckId', isEqualTo: deckId)
          .where('nextReviewDate', isLessThanOrEqualTo: now)
          .orderBy('nextReviewDate')
          .limit(limit);

      final querySnapshot = await cardsRef.get();
      return querySnapshot.docs.map((doc) => doc.data()['cardId'] as String).toList();
    } catch (e) {
      print('Error getting due cards: $e');
      return [];
    }
  }

  /// Get learning progress for a deck
  Future<LearnProgress> getDeckProgress(String deckId) async {
    if (_userId == null) {
      return LearnProgress(
        deckId: deckId,
        masteredCards: 0,
        learningCards: 0,
        newCards: 0,
        averageAccuracy: 0,
      );
    }

    try {
      // Get all cards in the deck
      final deckRef = _firestore.collection('decks').doc(deckId);
      final deckDoc = await deckRef.get();
      final totalCards = deckDoc.data()?['cardCount'] ?? 0;

      // Get progress for cards in this deck
      final progressRef = _progressCollection
          .doc(_userId)
          .collection('cards')
          .where('deckId', isEqualTo: deckId);
      final progressSnapshot = await progressRef.get();

      int masteredCards = 0;
      int learningCards = 0;
      int totalCorrect = 0;
      int totalReviews = 0;

      for (var doc in progressSnapshot.docs) {
        final data = doc.data();
        final correctRate = data['correctRate'] ?? 0.0;
        final reviewCount = data['totalReviews'] ?? 0;

        // Consider a card mastered if it has been reviewed at least 3 times
        // and has a correctRate of at least 90%
        if (reviewCount >= 3 && correctRate >= 0.9) {
          masteredCards++;
        } else if (reviewCount > 0) {
          learningCards++;
        }

        totalCorrect += data['correctReviews'] ?? 0;
        totalReviews += reviewCount;
      }

      // Cards that have never been reviewed
      final newCards = totalCards - masteredCards - learningCards;

      return LearnProgress(
        deckId: deckId,
        masteredCards: masteredCards,
        learningCards: learningCards,
        newCards: newCards < 0 ? 0 : newCards,
        averageAccuracy: totalReviews > 0 ? totalCorrect / totalReviews : 0,
      );
    } catch (e) {
      print('Error getting deck progress: $e');
      return LearnProgress(
        deckId: deckId,
        masteredCards: 0,
        learningCards: 0,
        newCards: 0,
        averageAccuracy: 0,
      );
    }
  }

  /// Get recent study sessions
  Future<List<StudySession>> getRecentSessions({
    int limit = 10,
    String? deckId,
  }) async {
    if (_userId == null) return [];

    try {
      Query<Map<String, dynamic>> query = _sessionsCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('endTime', descending: true)
          .limit(limit);

      if (deckId != null) {
        query = query.where('deckId', isEqualTo: deckId);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return StudySession(
          id: doc.id,
          deckId: data['deckId'] ?? '',
          totalCards: data['totalCards'] ?? 0,
          correctAnswers: data['correctAnswers'] ?? 0,
          date: (data['endTime'] as Timestamp).toDate(),
          durationSeconds: data['durationSeconds'] ?? 0,
        );
      }).toList();
    } catch (e) {
      print('Error getting recent sessions: $e');
      return [];
    }
  }

  /// Calculate the next review date based on spaced repetition algorithm
  DateTime _calculateNextReviewDate({
    required int lastConfidence,
    required int consecutiveCorrect,
  }) {
    // Spaced repetition algorithm
    // Interval is longer if:
    // 1. User has high confidence (4-5)
    // 2. User has answered correctly multiple times in a row
    
    int baseIntervalDays;
    
    // Base interval depends on confidence level
    switch (lastConfidence) {
      case 5: // Very easy
        baseIntervalDays = 7;
        break;
      case 4: // Easy
        baseIntervalDays = 4;
        break;
      case 3: // Medium
        baseIntervalDays = 2;
        break;
      case 2: // Hard
        baseIntervalDays = 1;
        break;
      case 1: // Very hard
      default:
        baseIntervalDays = 0; // Review the same day
        break;
    }
    
    // Adjust for consecutive correct answers
    double intervalMultiplier = 1.0;
    if (consecutiveCorrect > 1) {
      // Each consecutive correct answer increases interval
      // up to a maximum of 2.5x for 5+ consecutive correct answers
      intervalMultiplier = 1.0 + math.min(1.5, (consecutiveCorrect - 1) * 0.3);
    }
    
    final intervalDays = (baseIntervalDays * intervalMultiplier).round();
    return DateTime.now().add(Duration(days: intervalDays));
  }

  /// Calculate current streak days
  Future<int> _calculateStreakDays() async {
    if (_userId == null) return 0;

    try {
      // Get study sessions ordered by date
      final sessionsRef = _sessionsCollection
          .where('userId', isEqualTo: _userId)
          .orderBy('endTime', descending: true);
      final sessionsSnapshot = await sessionsRef.get();

      if (sessionsSnapshot.docs.isEmpty) {
        return 0;
      }

      final sessions = sessionsSnapshot.docs.map((doc) {
        return (doc.data()['endTime'] as Timestamp).toDate();
      }).toList();

      // Check if studied today
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      // If no study session today, streak is already broken
      if (sessions.first.isBefore(todayStart)) {
        return 0;
      }

      // Count consecutive days with study sessions
      int streakDays = 1; // Include today
      DateTime currentDate = todayStart.subtract(const Duration(days: 1));

      while (true) {
        final dayStart = DateTime(
          currentDate.year, 
          currentDate.month, 
          currentDate.day,
        );
        final dayEnd = dayStart.add(const Duration(days: 1));

        // Check if there's a session on this day
        final hasSessionOnDay = sessions.any((date) {
          return date.isAfter(dayStart) && date.isBefore(dayEnd);
        });

        if (hasSessionOnDay) {
          streakDays++;
          currentDate = currentDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      }

      return streakDays;
    } catch (e) {
      print('Error calculating streak days: $e');
      return 0;
    }
  }
}
