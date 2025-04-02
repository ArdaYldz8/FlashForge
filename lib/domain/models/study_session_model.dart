import 'package:intl/intl.dart';

/// Model representing a study session
class StudySession {
  /// Unique ID of the session
  final String id;
  
  /// ID of the deck studied
  final String deckId;
  
  /// Total number of cards reviewed
  final int totalCards;
  
  /// Number of correct answers
  final int correctAnswers;
  
  /// Date and time of the session
  final DateTime date;
  
  /// Duration of the session in seconds
  final int durationSeconds;

  /// Default constructor
  StudySession({
    required this.id,
    required this.deckId,
    required this.totalCards,
    required this.correctAnswers,
    required this.date,
    required this.durationSeconds,
  });

  /// Accuracy rate (0.0-1.0)
  double get accuracy => 
      totalCards > 0 ? correctAnswers / totalCards : 0.0;

  /// Accuracy percentage (0-100)
  int get accuracyPercentage => 
      (accuracy * 100).round();

  /// Formatted date (e.g., "Apr 3, 2025")
  String get formattedDate => 
      DateFormat.yMMMd().format(date);

  /// Formatted time (e.g., "3:30 PM")
  String get formattedTime => 
      DateFormat.jm().format(date);

  /// Formatted duration (e.g., "5m 30s")
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Create from JSON map
  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      id: json['id'] as String,
      deckId: json['deckId'] as String,
      totalCards: json['totalCards'] as int,
      correctAnswers: json['correctAnswers'] as int,
      date: DateTime.parse(json['date'] as String),
      durationSeconds: json['durationSeconds'] as int,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deckId': deckId,
      'totalCards': totalCards,
      'correctAnswers': correctAnswers,
      'date': date.toIso8601String(),
      'durationSeconds': durationSeconds,
    };
  }
}
