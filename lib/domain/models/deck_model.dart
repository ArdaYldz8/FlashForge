/// Model representing a deck of flashcards
class Deck {
  /// Unique identifier
  final String id;
  
  /// Title of the deck
  final String title;
  
  /// Description of the deck
  final String description;
  
  /// The user ID who owns this deck
  final String ownerId;
  
  /// Creation timestamp
  final DateTime createdAt;
  
  /// Last modified timestamp
  final DateTime updatedAt;
  
  /// Tags associated with this deck
  final List<String> tags;
  
  /// Language of the deck (ISO code)
  final String language;
  
  /// Whether the deck is public or private
  final bool isPublic;
  
  /// Total number of cards in the deck
  final int cardCount;
  
  /// Last time this deck was studied
  final DateTime? lastStudiedAt;
  
  /// Study progress as a percentage (0.0 to 1.0)
  final double progress;
  
  /// Constructor
  Deck({
    required this.id,
    required this.title,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.tags = const [],
    this.language = 'en',
    this.isPublic = false,
    this.cardCount = 0,
    this.lastStudiedAt,
    this.progress = 0.0,
  });
  
  /// Create a deck from a map (e.g., from JSON)
  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      ownerId: map['ownerId'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
      tags: List<String>.from(map['tags'] ?? []),
      language: map['language'] as String? ?? 'en',
      isPublic: map['isPublic'] as bool? ?? false,
      cardCount: map['cardCount'] as int? ?? 0,
      lastStudiedAt: map['lastStudiedAt'] != null
          ? DateTime.parse(map['lastStudiedAt'] as String)
          : null,
      progress: (map['progress'] as num?)?.toDouble() ?? 0.0,
    );
  }
  
  /// Convert the deck to a map (e.g., for JSON serialization)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ownerId': ownerId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tags': tags,
      'language': language,
      'isPublic': isPublic,
      'cardCount': cardCount,
      'lastStudiedAt': lastStudiedAt?.toIso8601String(),
      'progress': progress,
    };
  }
  
  /// Create a copy of this deck with some updated properties
  Deck copyWith({
    String? id,
    String? title,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? tags,
    String? language,
    bool? isPublic,
    int? cardCount,
    DateTime? lastStudiedAt,
    double? progress,
  }) {
    return Deck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
      language: language ?? this.language,
      isPublic: isPublic ?? this.isPublic,
      cardCount: cardCount ?? this.cardCount,
      lastStudiedAt: lastStudiedAt ?? this.lastStudiedAt,
      progress: progress ?? this.progress,
    );
  }
}
