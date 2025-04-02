import 'dart:convert';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:pdf/pdf.dart' as pdf;
import 'package:flashforge/config/app_config.dart';
import 'package:flashforge/domain/models/flashcard_model.dart';

/// Service to interact with AI models for flashcard generation
class AIService {
  /// Dio HTTP client for API requests
  final Dio _dio = Dio();
  
  /// Default model for text summarization
  static const String _defaultSummarizationModel = 'facebook/bart-large-cnn';
  
  /// Default model for question generation
  static const String _defaultQuestionGenerationModel = 'vblagoje/bart-large-xsum-samsum';
  
  /// Default model for answer generation
  static const String _defaultAnswerGenerationModel = 'google/flan-t5-base';
  
  /// Default constructor
  AIService() {
    _dio.options.headers['Authorization'] = 'Bearer ${AppConfig.huggingFaceApiToken}';
  }

  /// Generate flashcards from text content
  Future<List<Flashcard>> generateFlashcardsFromText({
    required String text,
    required String deckId,
    String? language,
    int maxCards = 10,
  }) async {
    // Validate input
    if (text.isEmpty) {
      throw Exception('Input text cannot be empty');
    }
    
    // Ensure we have an API token
    if (AppConfig.huggingFaceApiToken == null || AppConfig.huggingFaceApiToken!.isEmpty) {
      throw Exception('Hugging Face API token is required');
    }
    
    try {
      // 1. Extract key information from the text
      final keyPoints = await _extractKeyPoints(text, maxPoints: maxCards);
      
      // 2. Generate question-answer pairs
      final flashcards = await _generateQuestionAnswerPairs(keyPoints, deckId);
      
      return flashcards;
    } catch (e) {
      throw Exception('Failed to generate flashcards: $e');
    }
  }
  
  /// Extract key points from the text
  Future<List<String>> _extractKeyPoints(String text, {int maxPoints = 10}) async {
    try {
      final response = await _dio.post(
        'https://api-inference.huggingface.co/models/$_defaultSummarizationModel',
        data: jsonEncode({'inputs': text, 'parameters': {'max_length': 1000}}),
      );
      
      final result = response.data;
      if (result is List && result.isNotEmpty) {
        final summary = result[0]['summary_text'] as String;
        
        // Split the summary into sentences and take the top sentences as key points
        final sentences = _splitIntoSentences(summary);
        return sentences.take(maxPoints).toList();
      }
      
      return [];
    } catch (e) {
      throw Exception('Error extracting key points: $e');
    }
  }
  
  /// Generate question-answer pairs for flashcards
  Future<List<Flashcard>> _generateQuestionAnswerPairs(
    List<String> keyPoints,
    String deckId,
  ) async {
    final flashcards = <Flashcard>[];
    final now = DateTime.now();
    
    for (final point in keyPoints) {
      try {
        // Generate a question for this key point
        final question = await _generateQuestion(point);
        
        // Use the key point as the answer or generate a better answer
        final answer = point;
        
        // Create a flashcard
        final flashcard = Flashcard(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          question: question,
          answer: answer,
          deckId: deckId,
          createdAt: now,
          updatedAt: now,
        );
        
        flashcards.add(flashcard);
      } catch (e) {
        // Skip this point if generation fails
        print('Error generating flashcard for point: $point, Error: $e');
      }
    }
    
    return flashcards;
  }
  
  /// Generate a question for a given piece of text
  Future<String> _generateQuestion(String text) async {
    try {
      final prompt = 'Generate a study question based on this text: "$text"';
      
      final response = await _dio.post(
        'https://api-inference.huggingface.co/models/$_defaultQuestionGenerationModel',
        data: jsonEncode({'inputs': prompt}),
      );
      
      final result = response.data;
      if (result is List && result.isNotEmpty) {
        return result[0]['generated_text'] as String;
      }
      
      return 'What can you tell me about ${text.length > 50 ? '${text.substring(0, 50)}...' : text}?';
    } catch (e) {
      throw Exception('Error generating question: $e');
    }
  }
  
  /// Generate flashcards from a PDF document
  Future<List<Flashcard>> generateFlashcardsFromPdf({
    required Uint8List pdfBytes,
    required String deckId,
    String? language,
    int maxCards = 10,
  }) async {
    try {
      // Use the pdf package to extract text from the PDF
      final document = pdf.PdfDocument.openData(pdfBytes);
      String extractedText = '';
      
      // Extract text from each page
      for (var i = 0; i < document.pageCount; i++) {
        final page = document.page(i + 1);
        final pageText = await page.text;
        extractedText += pageText + '\n';
      }
      
      // Close the document
      document.dispose();
      
      // Use the text generation method
      return generateFlashcardsFromText(
        text: extractedText,
        deckId: deckId,
        language: language,
        maxCards: maxCards,
      );
    } catch (e) {
      throw Exception('Failed to generate flashcards from PDF: $e');
    }
  }
  
  /// Generate flashcards from an image
  Future<List<Flashcard>> generateFlashcardsFromImage({
    required Uint8List imageBytes,
    required String deckId,
    String? language,
    int maxCards = 10,
  }) async {
    try {
      // Convert the image to base64 for sending to OCR API
      final base64Image = base64Encode(imageBytes);
      
      // Call OCR API to extract text from image
      final response = await _dio.post(
        'https://api-inference.huggingface.co/models/microsoft/trocr-base-printed',
        data: jsonEncode({'inputs': base64Image}),
      );
      
      String extractedText = '';
      if (response.data is List && response.data.isNotEmpty) {
        extractedText = response.data[0]['generated_text'] as String;
      } else if (response.data is Map) {
        extractedText = response.data['generated_text'] as String? ?? '';
      }
      
      if (extractedText.isEmpty) {
        throw Exception('Failed to extract text from image');
      }
      
      // Use the text generation method
      return generateFlashcardsFromText(
        text: extractedText,
        deckId: deckId,
        language: language,
        maxCards: maxCards,
      );
    } catch (e) {
      throw Exception('Failed to generate flashcards from image: $e');
    }
  }
  
  /// Generate flashcards from a URL
  Future<List<Flashcard>> generateFlashcardsFromUrl({
    required String url,
    required String deckId,
    int maxCards = 10,
  }) async {
    // First, fetch the content from the URL
    try {
      final response = await _dio.get(url);
      final String html = response.data.toString();
      
      // Very simple HTML to text conversion (should use a proper HTML parser in production)
      final text = _extractTextFromHtml(html);
      
      // Use the text generation method
      return generateFlashcardsFromText(
        text: text,
        deckId: deckId,
        maxCards: maxCards,
      );
    } catch (e) {
      throw Exception('Failed to generate flashcards from URL: $e');
    }
  }
  
  /// Utility to split text into sentences
  List<String> _splitIntoSentences(String text) {
    // Basic sentence splitting - would need to be improved for production
    final sentenceRegex = RegExp(r'(?<=[.!?])\s+');
    return text.split(sentenceRegex)
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  }
  
  /// Very simple HTML to text conversion
  String _extractTextFromHtml(String html) {
    // Remove HTML tags
    var text = html.replaceAll(RegExp(r'<[^>]*>'), ' ');
    
    // Decode HTML entities
    text = text.replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'");
    
    // Normalize whitespace
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    return text;
  }
}
