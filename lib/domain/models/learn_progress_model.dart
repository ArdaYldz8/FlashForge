/// Model representing the learning progress of a deck
class LearnProgress {
  /// Deck ID
  final String deckId;
  
  /// Number of cards mastered (high confidence, multiple correct reviews)
  final int masteredCards;
  
  /// Number of cards being learned (reviewed but not mastered)
  final int learningCards;
  
  /// Number of cards not yet reviewed
  final int newCards;
  
  /// Average accuracy rate (0.0-1.0)
  final double averageAccuracy;

  /// Default constructor
  LearnProgress({
    required this.deckId,
    required this.masteredCards,
    required this.learningCards,
    required this.newCards,
    required this.averageAccuracy,
  });

  /// Total number of cards in the deck
  int get totalCards => masteredCards + learningCards + newCards;

  /// Percentage of cards mastered (0-100)
  int get masteredPercentage => 
      totalCards > 0 ? ((masteredCards / totalCards) * 100).round() : 0;

  /// Percentage of cards being learned (0-100)
  int get learningPercentage => 
      totalCards > 0 ? ((learningCards / totalCards) * 100).round() : 0;

  /// Percentage of new cards (0-100)
  int get newPercentage => 
      totalCards > 0 ? ((newCards / totalCards) * 100).round() : 0;

  /// Percentage of deck completion (0-100)
  int get completionPercentage => 
      totalCards > 0 
          ? (((masteredCards + (learningCards * 0.5)) / totalCards) * 100).round() 
          : 0;

  /// Formatted average accuracy percentage
  String get accuracyFormatted => 
      '${(averageAccuracy * 100).round()}%';

  /// Create from JSON map
  factory LearnProgress.fromJson(Map<String, dynamic> json) {
    return LearnProgress(
      deckId: json['deckId'] as String,
      masteredCards: json['masteredCards'] as int,
      learningCards: json['learningCards'] as int,
      newCards: json['newCards'] as int,
      averageAccuracy: json['averageAccuracy'] as double,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'deckId': deckId,
      'masteredCards': masteredCards,
      'learningCards': learningCards,
      'newCards': newCards,
      'averageAccuracy': averageAccuracy,
    };
  }
}
