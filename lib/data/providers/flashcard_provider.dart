import 'package:flashforge/domain/models/flashcard_model.dart';
import 'package:flashforge/domain/repositories/flashcard_repository.dart';
import 'package:riverpod/riverpod.dart';

/// Provider for flashcard state
class FlashcardNotifier extends StateNotifier<Map<String, List<Flashcard>>> {
  /// Repository for flashcard operations
  final FlashcardRepository _repository;
  
  /// Constructor
  FlashcardNotifier(this._repository) : super({});
  
  /// Load flashcards for a specific deck
  Future<List<Flashcard>> loadFlashcardsForDeck(String deckId) async {
    try {
      final flashcards = await _repository.getFlashcardsByDeckId(deckId);
      
      // Update state
      state = {
        ...state,
        deckId: flashcards,
      };
      
      return flashcards;
    } catch (e) {
      print('Error loading flashcards for deck: $e');
      
      // Return empty list on error but don't update state
      return [];
    }
  }
  
  /// Add a new flashcard
  Future<void> addFlashcard(Flashcard flashcard) async {
    try {
      await _repository.addFlashcard(flashcard);
      
      // Update state locally
      final deckFlashcards = state[flashcard.deckId] ?? [];
      state = {
        ...state,
        flashcard.deckId: [...deckFlashcards, flashcard],
      };
    } catch (e) {
      print('Error adding flashcard: $e');
      rethrow;
    }
  }
  
  /// Add multiple flashcards
  Future<void> addFlashcards(List<Flashcard> flashcards) async {
    if (flashcards.isEmpty) return;
    
    try {
      // Group flashcards by deck ID
      final Map<String, List<Flashcard>> flashcardsByDeck = {};
      
      for (final flashcard in flashcards) {
        flashcardsByDeck[flashcard.deckId] = [
          ...(flashcardsByDeck[flashcard.deckId] ?? []),
          flashcard,
        ];
        
        // Add each flashcard to repository
        await _repository.addFlashcard(flashcard);
      }
      
      // Update state for each affected deck
      final newState = Map<String, List<Flashcard>>.from(state);
      
      flashcardsByDeck.forEach((deckId, newFlashcards) {
        newState[deckId] = [
          ...(newState[deckId] ?? []),
          ...newFlashcards,
        ];
      });
      
      state = newState;
    } catch (e) {
      print('Error adding multiple flashcards: $e');
      rethrow;
    }
  }
  
  /// Update an existing flashcard
  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      await _repository.updateFlashcard(flashcard);
      
      // Update state locally
      final deckFlashcards = state[flashcard.deckId] ?? [];
      state = {
        ...state,
        flashcard.deckId: [
          for (final card in deckFlashcards)
            if (card.id == flashcard.id) flashcard else card,
        ],
      };
    } catch (e) {
      print('Error updating flashcard: $e');
      rethrow;
    }
  }
  
  /// Delete a flashcard
  Future<void> deleteFlashcard(Flashcard flashcard) async {
    try {
      await _repository.deleteFlashcard(flashcard.id);
      
      // Update state locally
      final deckFlashcards = state[flashcard.deckId] ?? [];
      state = {
        ...state,
        flashcard.deckId: deckFlashcards
            .where((card) => card.id != flashcard.id)
            .toList(),
      };
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }
  
  /// Update flashcard review status
  Future<void> updateFlashcardReviewStatus(
    String id,
    int difficultyLevel,
    String deckId,
  ) async {
    try {
      await _repository.updateFlashcardReviewStatus(id, difficultyLevel);
      
      // Find the flashcard in the state
      final deckFlashcards = state[deckId] ?? [];
      final flashcardIndex = deckFlashcards.indexWhere((card) => card.id == id);
      
      if (flashcardIndex >= 0) {
        // Calculate next review time based on difficulty
        final now = DateTime.now();
        final nextReview = _calculateNextReview(now, difficultyLevel);
        
        // Create updated flashcard
        final updatedCard = deckFlashcards[flashcardIndex].copyWith(
          difficultyLevel: difficultyLevel,
          lastReviewedAt: now,
          nextReviewAt: nextReview,
        );
        
        // Update state
        final updatedDeckFlashcards = List<Flashcard>.from(deckFlashcards);
        updatedDeckFlashcards[flashcardIndex] = updatedCard;
        
        state = {
          ...state,
          deckId: updatedDeckFlashcards,
        };
      }
    } catch (e) {
      print('Error updating flashcard review status: $e');
      rethrow;
    }
  }
  
  /// Get flashcards due for review
  Future<List<Flashcard>> getFlashcardsDueForReview() async {
    try {
      final now = DateTime.now();
      return await _repository.getFlashcardsDueForReview(now);
    } catch (e) {
      print('Error getting flashcards due for review: $e');
      return [];
    }
  }
  
  /// Calculate next review time based on difficulty
  DateTime _calculateNextReview(DateTime now, int difficultyLevel) {
    // Simple spaced repetition algorithm
    // 1: Very Hard - review in 1 day
    // 2: Hard - review in 3 days
    // 3: Medium - review in 7 days
    // 4: Easy - review in 14 days
    // 5: Very Easy - review in 30 days
    
    final Map<int, int> difficultyToDays = {
      1: 1,
      2: 3,
      3: 7,
      4: 14,
      5: 30,
    };
    
    final days = difficultyToDays[difficultyLevel] ?? 7;
    return now.add(Duration(days: days));
  }
}
