import 'package:flashforge/domain/models/deck_model.dart';

/// Interface for accessing deck data
abstract class DeckRepository {
  /// Get all decks for the current user
  Future<List<Deck>> getAllDecks();
  
  /// Get a specific deck by ID
  Future<Deck?> getDeckById(String id);
  
  /// Add a new deck
  Future<String> addDeck(Deck deck);
  
  /// Update an existing deck
  Future<void> updateDeck(Deck deck);
  
  /// Delete a deck and all its flashcards
  Future<void> deleteDeck(String id);
  
  /// Search decks by title or description
  Future<List<Deck>> searchDecks(String query);
  
  /// Update deck study progress
  Future<void> updateDeckProgress(String id, double progress);
  
  /// Get recently studied decks
  Future<List<Deck>> getRecentlyStudiedDecks(int limit);
}
