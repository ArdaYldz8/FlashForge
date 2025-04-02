import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flashforge/data/providers/ai_service_provider.dart';
import 'package:flashforge/data/providers/deck_provider.dart';
import 'package:flashforge/data/providers/flashcard_provider.dart';
import 'package:flashforge/data/repositories/firebase_deck_repository.dart';
import 'package:flashforge/data/repositories/firebase_flashcard_repository.dart';
import 'package:flashforge/domain/models/deck_model.dart';
import 'package:flashforge/domain/models/flashcard_model.dart';
import 'package:flashforge/domain/repositories/deck_repository.dart';
import 'package:flashforge/domain/repositories/flashcard_repository.dart';
import 'package:flashforge/domain/services/ai_service.dart';
import 'package:riverpod/riverpod.dart';

/// Firebase Auth provider
final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);

/// Firebase Firestore provider
final firestoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

/// Deck repository provider
final deckRepositoryProvider = Provider<DeckRepository>(
  (ref) => FirebaseDeckRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(firebaseAuthProvider),
  ),
);

/// Flashcard repository provider
final flashcardRepositoryProvider = Provider<FlashcardRepository>(
  (ref) => FirebaseFlashcardRepository(
    firestore: ref.read(firestoreProvider),
    auth: ref.read(firebaseAuthProvider),
  ),
);

/// AI service provider
final aiServiceProvider = Provider<AIService>(
  (ref) => AIService(),
);

/// Decks state provider
final decksProvider = StateNotifierProvider<DeckNotifier, List<Deck>>(
  (ref) => DeckNotifier(ref.read(deckRepositoryProvider)),
);

/// Flashcards state provider
final flashcardsProvider = StateNotifierProvider<FlashcardNotifier, Map<String, List<Flashcard>>>(
  (ref) => FlashcardNotifier(ref.read(flashcardRepositoryProvider)),
);

/// AI service state provider
final aiServiceNotifierProvider = StateNotifierProvider<AIServiceNotifier, AsyncValue<void>>(
  (ref) => AIServiceNotifier(ref.read(aiServiceProvider)),
);

/// Recently studied decks provider
final recentlyStudiedDecksProvider = Provider<List<Deck>>(
  (ref) {
    // Get decks and filter for recently studied
    final decks = ref.watch(decksProvider);
    final sortedDecks = List<Deck>.from(decks)
      ..sort((a, b) => (b.lastStudiedAt ?? DateTime(1900))
          .compareTo(a.lastStudiedAt ?? DateTime(1900)));
    
    return sortedDecks.take(5).toList();
  },
);

/// Theme mode provider
final themeModeProvider = StateProvider<ThemeMode>(
  (ref) => ThemeMode.system,
);

/// Current user provider
final currentUserProvider = StreamProvider<User?>(
  (ref) => ref.read(firebaseAuthProvider).authStateChanges(),
);

/// Selected language provider
final selectedLanguageProvider = StateProvider<String>(
  (ref) => 'English',
);

/// Authentication state provider
final authStateProvider = Provider<AsyncValue<bool>>(
  (ref) {
    final userAsyncValue = ref.watch(currentUserProvider);
    
    return userAsyncValue.when(
      data: (user) => AsyncValue.data(user != null),
      loading: () => const AsyncValue.loading(),
      error: (error, stackTrace) => AsyncValue.error(error, stackTrace),
    );
  },
);
