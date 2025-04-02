import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashforge/data/providers/providers.dart';
import 'package:flashforge/domain/models/deck_model.dart';
import 'package:flashforge/presentation/routes/app_router.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Screen for creating a new deck
class CreateDeckScreen extends ConsumerStatefulWidget {
  /// Default constructor
  const CreateDeckScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CreateDeckScreen> createState() => _CreateDeckScreenState();
}

class _CreateDeckScreenState extends ConsumerState<CreateDeckScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  String _selectedCategory = 'General';
  bool _isPublic = false;
  bool _isLoading = false;
  
  // Category options
  final List<String> _categories = [
    'General',
    'Science',
    'Mathematics',
    'History',
    'Languages',
    'Arts',
    'Technology',
    'Business',
    'Other'
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Deck'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildForm(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header image
          _buildHeaderImage(),
          const SizedBox(height: 24.0),
          
          // Title field
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Enter deck title',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title for your deck';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          
          // Description field
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter deck description',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            maxLines: 3,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a description for your deck';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          
          // Category dropdown
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              prefixIcon: const Icon(Icons.category),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            items: _categories.map((String category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedCategory = newValue;
                });
              }
            },
          ),
          const SizedBox(height: 24.0),
          
          // Public switch
          SwitchListTile(
            title: const Text('Make deck public'),
            subtitle: const Text('Public decks can be discovered by other users'),
            value: _isPublic,
            activeColor: AppTheme.primaryColor,
            onChanged: (bool value) {
              setState(() {
                _isPublic = value;
              });
            },
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
              side: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(height: 16.0),
          
          // Tags info
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8.0),
                      Text(
                        'Tips for a Great Deck',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '• Give your deck a clear, descriptive title\n'
                    '• Add a detailed description to help with search\n'
                    '• Choose the most relevant category\n'
                    '• Later, you can add tags to make your deck more discoverable',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.asset(
        'assets/images/create_deck.png',
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 160,
            width: double.infinity,
            color: AppTheme.primaryColor.withOpacity(0.1),
            child: Icon(
              Icons.style,
              size: 64,
              color: AppTheme.primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: 16.0),
          
          // Create button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _createDeck,
              child: const Text('Create Deck'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createDeck() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create new deck
      final newDeck = Deck(
        id: '', // Will be set by Firebase
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        isPublic: _isPublic,
        cardCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        ownerId: ref.read(firebaseAuthProvider).currentUser?.uid ?? '',
      );
      
      // Add to repository
      final deckId = await ref.read(decksProvider.notifier).addDeck(newDeck);
      
      // Navigate to create flashcard screen with the new deck ID
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(
          AppRouter.createFlashcardRoute,
          arguments: {'deckId': deckId},
        );
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating deck: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
