import 'package:flashforge/domain/models/deck_model.dart';
import 'package:flashforge/domain/repositories/deck_repository.dart';
import 'package:riverpod/riverpod.dart';

/// Provider for deck state
class DeckNotifier extends StateNotifier<List<Deck>> {
  /// Repository for deck operations
  final DeckRepository _repository;
  
  /// Constructor
  DeckNotifier(this._repository) : super([]) {
    _loadDecks();
  }
  
  /// Load all decks
  Future<void> _loadDecks() async {
    try {
      final decks = await _repository.getAllDecks();
      state = decks;
    } catch (e) {
      // Handle error
      print('Error loading decks: $e');
      state = [];
    }
  }
  
  /// Refresh the deck list
  Future<void> refreshDecks() async {
    await _loadDecks();
  }
  
  /// Add a new deck
  Future<String> addDeck(Deck deck) async {
    try {
      final deckId = await _repository.addDeck(deck);
      await _loadDecks(); // Reload decks to reflect the new state
      return deckId;
    } catch (e) {
      print('Error adding deck: $e');
      rethrow;
    }
  }
  
  /// Update an existing deck
  Future<void> updateDeck(Deck deck) async {
    try {
      await _repository.updateDeck(deck);
      
      // Update state locally to avoid reloading all decks
      state = [
        for (final existingDeck in state)
          if (existingDeck.id == deck.id) deck else existingDeck,
      ];
    } catch (e) {
      print('Error updating deck: $e');
      rethrow;
    }
  }
  
  /// Delete a deck
  Future<void> deleteDeck(String id) async {
    try {
      await _repository.deleteDeck(id);
      
      // Update state locally to avoid reloading all decks
      state = state.where((deck) => deck.id != id).toList();
    } catch (e) {
      print('Error deleting deck: $e');
      rethrow;
    }
  }
  
  /// Update deck progress
  Future<void> updateDeckProgress(String id, double progress) async {
    try {
      await _repository.updateDeckProgress(id, progress);
      
      // Update state locally
      state = [
        for (final deck in state)
          if (deck.id == id)
            deck.copyWith(progress: progress, updatedAt: DateTime.now())
          else
            deck,
      ];
    } catch (e) {
      print('Error updating deck progress: $e');
      rethrow;
    }
  }
  
  /// Get a specific deck by ID
  Deck? getDeckById(String id) {
    try {
      return state.firstWhere((deck) => deck.id == id);
    } catch (_) {
      return null;
    }
  }
  
  /// Get recently studied decks
  List<Deck> getRecentlyStudiedDecks(int limit) {
    final sortedDecks = List<Deck>.from(state)
      ..sort((a, b) => (b.lastStudiedAt ?? DateTime(1900))
          .compareTo(a.lastStudiedAt ?? DateTime(1900)));
    
    return sortedDecks.take(limit).toList();
  }
}
