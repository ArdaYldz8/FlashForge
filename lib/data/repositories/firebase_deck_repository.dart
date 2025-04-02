import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashforge/domain/models/deck_model.dart';
import 'package:flashforge/domain/repositories/deck_repository.dart';

/// Firebase implementation of the deck repository
class FirebaseDeckRepository implements DeckRepository {
  /// Firestore instance
  final FirebaseFirestore _firestore;
  
  /// Firebase Auth instance
  final FirebaseAuth _auth;
  
  /// Constructor
  FirebaseDeckRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Reference to the decks collection
  CollectionReference get _decksRef => _firestore.collection('decks');
  
  /// Get user ID or throw if not authenticated
  String get _userId {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.uid;
  }

  @override
  Future<List<Deck>> getAllDecks() async {
    try {
      final querySnapshot = await _decksRef
          .where('ownerId', isEqualTo: _userId)
          .orderBy('updatedAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Deck.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Error getting all decks: $e');
      rethrow;
    }
  }

  @override
  Future<Deck?> getDeckById(String id) async {
    try {
      final docSnapshot = await _decksRef.doc(id).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      return Deck.fromMap({
        'id': docSnapshot.id,
        ...docSnapshot.data() as Map<String, dynamic>,
      });
    } catch (e) {
      print('Error getting deck by ID: $e');
      rethrow;
    }
  }

  @override
  Future<String> addDeck(Deck deck) async {
    try {
      // Create a new document with a generated ID
      final docRef = _decksRef.doc();
      
      // Prepare deck data with current user ID
      final deckData = {
        ...deck.toMap(),
        'ownerId': _userId,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Remove the ID field since Firestore generates it
      (deckData as Map<String, dynamic>).remove('id');
      
      // Add the deck to Firestore
      await docRef.set(deckData);
      
      return docRef.id;
    } catch (e) {
      print('Error adding deck: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateDeck(Deck deck) async {
    try {
      // Ensure the deck exists and belongs to the current user
      final deckDoc = await _decksRef.doc(deck.id).get();
      
      if (!deckDoc.exists) {
        throw Exception('Deck not found');
      }
      
      final deckData = deckDoc.data() as Map<String, dynamic>;
      
      if (deckData['ownerId'] != _userId) {
        throw Exception('Not authorized to update this deck');
      }
      
      // Prepare update data
      final updateData = {
        ...deck.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      // Remove fields that should not be updated
      updateData.remove('id');
      updateData.remove('ownerId');
      updateData.remove('createdAt');
      
      // Update the deck
      await _decksRef.doc(deck.id).update(updateData);
    } catch (e) {
      print('Error updating deck: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteDeck(String id) async {
    try {
      // Ensure the deck exists and belongs to the current user
      final deckDoc = await _decksRef.doc(id).get();
      
      if (!deckDoc.exists) {
        throw Exception('Deck not found');
      }
      
      final deckData = deckDoc.data() as Map<String, dynamic>;
      
      if (deckData['ownerId'] != _userId) {
        throw Exception('Not authorized to delete this deck');
      }
      
      // Delete the deck
      await _decksRef.doc(id).delete();
      
      // Delete all flashcards in the deck
      final flashcardsRef = _firestore.collection('flashcards');
      final querySnapshot = await flashcardsRef
          .where('deckId', isEqualTo: id)
          .get();
      
      // Batch delete flashcards
      final batch = _firestore.batch();
      for (final doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error deleting deck: $e');
      rethrow;
    }
  }

  @override
  Future<List<Deck>> searchDecks(String query) async {
    try {
      // Normalize the query
      final normalizedQuery = query.trim().toLowerCase();
      
      if (normalizedQuery.isEmpty) {
        return [];
      }
      
      // Get all user decks (Firestore doesn't support full-text search)
      final querySnapshot = await _decksRef
          .where('ownerId', isEqualTo: _userId)
          .get();
      
      // Filter decks client-side
      return querySnapshot.docs
          .map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Deck.fromMap({
              'id': doc.id,
              ...data,
            });
          })
          .where((deck) {
            final title = deck.title.toLowerCase();
            final description = deck.description.toLowerCase();
            return title.contains(normalizedQuery) ||
                description.contains(normalizedQuery);
          })
          .toList();
    } catch (e) {
      print('Error searching decks: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateDeckProgress(String id, double progress) async {
    try {
      // Validate progress value
      if (progress < 0 || progress > 1) {
        throw ArgumentError('Progress must be between 0 and 1');
      }
      
      // Update deck progress and last studied timestamp
      await _decksRef.doc(id).update({
        'progress': progress,
        'lastStudiedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating deck progress: $e');
      rethrow;
    }
  }

  @override
  Future<List<Deck>> getRecentlyStudiedDecks(int limit) async {
    try {
      final querySnapshot = await _decksRef
          .where('ownerId', isEqualTo: _userId)
          .where('lastStudiedAt', isNull: false)
          .orderBy('lastStudiedAt', descending: true)
          .limit(limit)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Deck.fromMap({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Error getting recently studied decks: $e');
      rethrow;
    }
  }
}
