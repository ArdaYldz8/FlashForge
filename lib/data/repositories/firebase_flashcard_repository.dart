import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashforge/domain/models/flashcard_model.dart';
import 'package:flashforge/domain/repositories/flashcard_repository.dart';

/// Firebase implementation of the flashcard repository
class FirebaseFlashcardRepository implements FlashcardRepository {
  /// Firestore instance
  final FirebaseFirestore _firestore;
  
  /// Firebase Auth instance
  final FirebaseAuth _auth;
  
  /// Constructor
  FirebaseFlashcardRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Reference to the flashcards collection
  CollectionReference get _flashcardsRef => _firestore.collection('flashcards');
  
  /// Get user ID or throw if not authenticated
  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  @override
  Future<List<Flashcard>> getFlashcardsByDeckId(String deckId) async {
    try {
      final querySnapshot = await _flashcardsRef
          .where('deckId', isEqualTo: deckId)
          .orderBy('createdAt', descending: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Flashcard.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Error getting flashcards by deck ID: $e');
      rethrow;
    }
  }

  @override
  Future<Flashcard?> getFlashcardById(String id) async {
    try {
      final docSnapshot = await _flashcardsRef.doc(id).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      return Flashcard.fromMap({
        'id': docSnapshot.id,
        ...docSnapshot.data() as Map<String, dynamic>,
      });
    } catch (e) {
      print('Error getting flashcard by ID: $e');
      rethrow;
    }
  }

  @override
  Future<void> addFlashcard(Flashcard flashcard) async {
    try {
      // Create a new document with a generated ID or use the provided ID
      final docRef = flashcard.id.isEmpty
          ? _flashcardsRef.doc()
          : _flashcardsRef.doc(flashcard.id);
      
      // Prepare flashcard data
      final flashcardData = {
        ...flashcard.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Remove the ID field since Firestore generates it
      (flashcardData as Map<String, dynamic>).remove('id');
      
      // Add the flashcard to Firestore
      await docRef.set(flashcardData);
    } catch (e) {
      print('Error adding flashcard: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateFlashcard(Flashcard flashcard) async {
    try {
      // Prepare update data
      final updateData = {
        ...flashcard.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Remove fields that should not be updated
      updateData.remove('id');
      updateData.remove('createdAt');
      
      // Update the flashcard
      await _flashcardsRef.doc(flashcard.id).update(updateData);
    } catch (e) {
      print('Error updating flashcard: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteFlashcard(String id) async {
    try {
      await _flashcardsRef.doc(id).delete();
    } catch (e) {
      print('Error deleting flashcard: $e');
      rethrow;
    }
  }

  @override
  Future<List<Flashcard>> getFlashcardsDueForReview(DateTime before) async {
    try {
      // Get decks owned by the current user
      final decksRef = _firestore.collection('decks');
      final decksSnapshot = await decksRef
          .where('ownerId', isEqualTo: _userId)
          .get();
      
      final deckIds = decksSnapshot.docs.map((doc) => doc.id).toList();
      
      if (deckIds.isEmpty) {
        return [];
      }
      
      // Query for flashcards due for review in the user's decks
      final querySnapshot = await _flashcardsRef
          .where('deckId', whereIn: deckIds)
          .where('nextReviewAt', isLessThanOrEqualTo: before)
          .orderBy('nextReviewAt', descending: false)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Flashcard.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Error getting flashcards due for review: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateFlashcardReviewStatus(String id, int difficultyLevel) async {
    try {
      // Validate difficulty level
      if (difficultyLevel < 1 || difficultyLevel > 5) {
        throw ArgumentError('Difficulty level must be between 1 and 5');
      }
      
      // Get current flashcard
      final docSnapshot = await _flashcardsRef.doc(id).get();
      
      if (!docSnapshot.exists) {
        throw Exception('Flashcard not found');
      }
      
      // Calculate next review time
      final now = DateTime.now();
      final nextReview = _calculateNextReview(now, difficultyLevel);
      
      // Update flashcard review status
      await _flashcardsRef.doc(id).update({
        'difficultyLevel': difficultyLevel,
        'lastReviewedAt': FieldValue.serverTimestamp(),
        'nextReviewAt': nextReview,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating flashcard review status: $e');
      rethrow;
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
