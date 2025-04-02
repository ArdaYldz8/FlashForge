import 'dart:io';
import 'dart:typed_data';

import 'package:flashforge/config/app_config.dart';
import 'package:flashforge/domain/models/flashcard_model.dart';
import 'package:flashforge/domain/services/ai_service.dart';
import 'package:flashforge/utils/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for AI service
class AIServiceNotifier extends StateNotifier<AsyncValue<void>> {
  /// AI service for flashcard generation
  final AIService _aiService;
  
  /// Constructor
  AIServiceNotifier(this._aiService) : super(const AsyncValue.data(null));
  
  /// Generate flashcards from text
  Future<List<Flashcard>> generateFlashcardsFromText({
    required String text,
    required String deckId,
    String? language,
    int maxCards = 10,
  }) async {
    // Update state to loading
    state = const AsyncValue.loading();
    
    try {
      // Generate flashcards
      final flashcards = await _aiService.generateFlashcardsFromText(
        text: text,
        deckId: deckId,
        language: language ?? AppConfig.preferredLanguage,
        maxCards: maxCards,
      );
      
      // Log analytics event
      await AnalyticsService.logFlashcardCreated(
        deckId: deckId,
        method: 'text',
        count: flashcards.length,
      );
      
      // Update state to data
      state = const AsyncValue.data(null);
      
      return flashcards;
    } catch (e, stackTrace) {
      // Update state to error
      state = AsyncValue.error(e, stackTrace);
      
      // Rethrow the error
      rethrow;
    }
  }
  
  /// Generate flashcards from URL
  /// Generate flashcards from a URL
  Future<List<Flashcard>> generateFlashcardsFromUrl({
    required String url,
    required String deckId,
    int maxCards = 10,
  }) async {
    // Update state to loading
    state = const AsyncValue.loading();
    
    try {
      // Generate flashcards
      final flashcards = await _aiService.generateFlashcardsFromUrl(
        url: url,
        deckId: deckId,
        maxCards: maxCards,
      );
      
      // Log analytics event
      await AnalyticsService.logFlashcardCreated(
        deckId: deckId,
        method: 'url',
        count: flashcards.length,
      );
      
      // Update state to data
      state = const AsyncValue.data(null);
      
      return flashcards;
    } catch (e, stackTrace) {
      // Update state to error
      state = AsyncValue.error(e, stackTrace);
      
      // Rethrow the error
      rethrow;
    }
  }
  
  /// Generate flashcards from PDF
  Future<List<Flashcard>> generateFlashcardsFromPdf({
    required Uint8List pdfBytes,
    required String deckId,
    String? language,
    int maxCards = 10,
  }) async {
    // Update state to loading
    state = const AsyncValue.loading();
    
    try {
      // Generate flashcards
      final flashcards = await _aiService.generateFlashcardsFromPdf(
        pdfBytes: pdfBytes,
        deckId: deckId,
        language: language ?? AppConfig.preferredLanguage,
        maxCards: maxCards,
      );
      
      // Log analytics event
      await AnalyticsService.logFlashcardCreated(
        deckId: deckId,
        method: 'pdf',
        count: flashcards.length,
      );
      
      // Update state to data
      state = const AsyncValue.data(null);
      
      return flashcards;
    } catch (e, stackTrace) {
      // Update state to error
      state = AsyncValue.error(e, stackTrace);
      
      // Rethrow the error
      rethrow;
    }
  }
  
  /// Generate flashcards from image
  Future<List<Flashcard>> generateFlashcardsFromImage({
    required Uint8List imageBytes,
    required String deckId,
    String? language,
    int maxCards = 10,
  }) async {
    // Update state to loading
    state = const AsyncValue.loading();
    
    try {
      // Generate flashcards
      final flashcards = await _aiService.generateFlashcardsFromImage(
        imageBytes: imageBytes,
        deckId: deckId,
        language: language ?? AppConfig.preferredLanguage,
        maxCards: maxCards,
      );
      
      // Log analytics event
      await AnalyticsService.logFlashcardCreated(
        deckId: deckId,
        method: 'image',
        count: flashcards.length,
      );
      
      // Update state to data
      state = const AsyncValue.data(null);
      
      return flashcards;
    } catch (e, stackTrace) {
      // Update state to error
      state = AsyncValue.error(e, stackTrace);
      
      // Rethrow the error
      rethrow;
    }
  }
}
