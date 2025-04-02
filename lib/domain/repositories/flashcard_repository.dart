import 'package:flashforge/domain/models/flashcard_model.dart';

/// Interface for accessing flashcard data
abstract class FlashcardRepository {
  /// Get all flashcards for a specific deck
  Future<List<Flashcard>> getFlashcardsByDeckId(String deckId);
  
  /// Get a specific flashcard by ID
  Future<Flashcard?> getFlashcardById(String id);
  
  /// Add a new flashcard
  Future<void> addFlashcard(Flashcard flashcard);
  
  /// Update an existing flashcard
  Future<void> updateFlashcard(Flashcard flashcard);
  
  /// Delete a flashcard
  Future<void> deleteFlashcard(String id);
  
  /// Get all flashcards due for review
  Future<List<Flashcard>> getFlashcardsDueForReview(DateTime before);
  
  /// Update flashcard review status (spaced repetition)
  Future<void> updateFlashcardReviewStatus(String id, int difficultyLevel);
}
