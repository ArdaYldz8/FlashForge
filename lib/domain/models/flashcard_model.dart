/// Model representing a flashcard
class Flashcard {
  /// Unique identifier
  final String id;
  
  /// The question or front side of the flashcard
  final String question;
  
  /// The answer or back side of the flashcard
  final String answer;
  
  /// The deck ID this card belongs to
  final String deckId;
  
  /// The creation timestamp
  final DateTime createdAt;
  
  /// The last modified timestamp
  final DateTime updatedAt;
  
  /// Optional metadata like confidence score, tags, etc.
  final Map<String, dynamic>? metadata;
  
  /// A number representing the difficulty level (1-5)
  final int difficultyLevel;
  
  /// Last time this card was reviewed
  final DateTime? lastReviewedAt;
  
  /// Next scheduled review time based on spaced repetition
  final DateTime? nextReviewAt;
  
  /// Constructor
  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    required this.deckId,
    required this.createdAt,
    required this.updatedAt,
    this.metadata,
    this.difficultyLevel = 3,
    this.lastReviewedAt,
    this.nextReviewAt,
  });
  
  /// Create a flashcard from a map (e.g., from JSON)
  factory Flashcard.fromMap(Map<String, dynamic> map) {
    return Flashcard(
      id: map['id'] as String,
      question: map['question'] as String,
      answer: map['answer'] as String,
      deckId: map['deckId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      metadata: map['metadata'] as Map<String, dynamic>?,
      difficultyLevel: map['difficultyLevel'] as int? ?? 3,
      lastReviewedAt: map['lastReviewedAt'] != null
          ? DateTime.parse(map['lastReviewedAt'] as String)
          : null,
      nextReviewAt: map['nextReviewAt'] != null
          ? DateTime.parse(map['nextReviewAt'] as String)
          : null,
    );
  }
  
  /// Convert the flashcard to a map (e.g., for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'deckId': deckId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
      'difficultyLevel': difficultyLevel,
      'lastReviewedAt': lastReviewedAt?.toIso8601String(),
      'nextReviewAt': nextReviewAt?.toIso8601String(),
    };
  }
  
  /// Create a copy of this flashcard with some updated properties
  Flashcard copyWith({
    String? id,
    String? question,
    String? answer,
    String? deckId,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
    int? difficultyLevel,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) {
    return Flashcard(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      deckId: deckId ?? this.deckId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }
}
