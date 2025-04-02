import 'package:flutter/material.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Screen to create new flashcards
class CreateFlashcardScreen extends StatefulWidget {
  /// Default constructor
  const CreateFlashcardScreen({Key? key}) : super(key: key);

  @override
  State<CreateFlashcardScreen> createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends State<CreateFlashcardScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();
  
  // Text editing controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contentController = TextEditingController();
  
  // Selected input type
  String _selectedInputType = 'Text';
  
  // Selected language
  String _selectedLanguage = 'English';
  
  // Loading state
  bool _isGenerating = false;
  
  // Cards generated
  bool _cardsGenerated = false;
  
  // Mock generated flashcards
  final List<Map<String, String>> _generatedFlashcards = [];

  // Input type options
  final List<String> _inputTypes = [
    'Text',
    'PDF',
    'Image',
    'URL',
  ];
  
  // Language options
  final List<String> _languages = [
    'English',
    'Spanish',
    'Turkish',
  ];
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Create Flashcards'),
      ),
      body: _cardsGenerated
          ? _buildGeneratedFlashcardsView()
          : _buildCreateFlashcardsForm(),
    );
  }
  
  /// Build the form to create flashcards
  Widget _buildCreateFlashcardsForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deck title
            Text(
              'Deck Title',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter a name for your deck',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            
            // Deck description
            Text(
              'Deck Description',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                hintText: 'Enter a description',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            
            // Input type
            Text(
              'Input Type',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedInputType,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.input),
              ),
              items: _inputTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedInputType = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Language
            Text(
              'Language',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.language),
              ),
              items: _languages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            
            // Content
            Text(
              'Content',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            _selectedInputType == 'Text'
                ? TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(
                      hintText: 'Paste your notes, text, or topics here',
                    ),
                    maxLines: 8,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some content';
                      }
                      return null;
                    },
                  )
                : OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement file picking
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('File upload coming soon!'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.upload_file),
                    label: Text('Upload ${_selectedInputType}'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      minimumSize: const Size(double.infinity, 60),
                    ),
                  ),
            const SizedBox(height: 32),
            
            // AI Options
            Text(
              'AI Options',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // Difficulty level
            Row(
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Difficulty Level',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                DropdownButton<String>(
                  value: 'Adaptive',
                  underline: Container(),
                  items: const [
                    DropdownMenuItem(
                      value: 'Beginner',
                      child: Text('Beginner'),
                    ),
                    DropdownMenuItem(
                      value: 'Intermediate',
                      child: Text('Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: 'Advanced',
                      child: Text('Advanced'),
                    ),
                    DropdownMenuItem(
                      value: 'Adaptive',
                      child: Text('Adaptive'),
                    ),
                  ],
                  onChanged: (value) {
                    // TODO: Implement difficulty change
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Include definitions
            Row(
              children: [
                const Icon(
                  Icons.book,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Include Definitions',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: true,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    // TODO: Implement switch change
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Include examples
            Row(
              children: [
                const Icon(
                  Icons.format_quote,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Include Examples',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                Switch(
                  value: true,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    // TODO: Implement switch change
                  },
                ),
              ],
            ),
            const SizedBox(height: 32),
            
            // Generate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isGenerating ? null : _generateFlashcards,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isGenerating
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Generating...'),
                        ],
                      )
                    : const Text('Generate Flashcards'),
              ),
            ),
            const SizedBox(height: 16),
            
            if (_selectedInputType == 'Text' && _contentController.text.isEmpty)
              // Example content box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Example Content',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Cell Theory: The cell is the basic unit of life. All living organisms are composed of cells. Cells arise from pre-existing cells.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _titleController.text = 'Biology 101';
                          _descriptionController.text = 'Basic principles of cell biology';
                          _contentController.text = 'Cell Theory: The cell is the basic unit of life. All living organisms are composed of cells. Cells arise from pre-existing cells.\n\nCell Structure: Cells contain organelles that perform specific functions.\n\nPhotosynthesis: A process by which plants convert light energy into chemical energy.';
                        });
                      },
                      child: const Text('Use Example'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  /// Build the view to display generated flashcards
  Widget _buildGeneratedFlashcardsView() {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generated Flashcards',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Review and edit these cards before saving them to your deck',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                _titleController.text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _descriptionController.text,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                '${_generatedFlashcards.length} flashcards generated',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        
        // Flashcards list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _generatedFlashcards.length,
            itemBuilder: (context, index) {
              final flashcard = _generatedFlashcards[index];
              return _buildFlashcardItem(
                index: index + 1,
                question: flashcard['question'] ?? '',
                answer: flashcard['answer'] ?? '',
              );
            },
          ),
        ),
        
        // Save button
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _cardsGenerated = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back to Edit'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _saveDeck,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Save Deck'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  /// Build a flashcard item
  Widget _buildFlashcardItem({
    required int index,
    required String question,
    required String answer,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card number
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Card #$index',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Question
            Text(
              'Question:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: question,
              decoration: const InputDecoration(
                hintText: 'Enter question',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              onChanged: (value) {
                _generatedFlashcards[index - 1]['question'] = value;
              },
            ),
            const SizedBox(height: 16),
            
            // Answer
            Text(
              'Answer:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: answer,
              decoration: const InputDecoration(
                hintText: 'Enter answer',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              maxLines: 3,
              onChanged: (value) {
                _generatedFlashcards[index - 1]['answer'] = value;
              },
            ),
            const SizedBox(height: 12),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Delete button
                IconButton(
                  onPressed: () {
                    setState(() {
                      _generatedFlashcards.removeAt(index - 1);
                    });
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  tooltip: 'Delete',
                ),
                // Regenerate button
                IconButton(
                  onPressed: () {
                    // TODO: Implement regenerate
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Regenerate feature coming soon!'),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.refresh,
                    color: AppTheme.primaryColor,
                  ),
                  tooltip: 'Regenerate',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Generate flashcards
  void _generateFlashcards() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isGenerating = true;
      });
      
      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        // Mock data - in real app, this would come from the Hugging Face API
        final mockFlashcards = [
          {
            'question': 'What is the cell theory?',
            'answer': 'The cell theory states that: 1) The cell is the basic unit of life, 2) All living organisms are composed of cells, and 3) Cells arise from pre-existing cells.',
          },
          {
            'question': 'What are the main components of a cell?',
            'answer': 'The main components of a cell include the cell membrane, cytoplasm, nucleus (in eukaryotes), and various organelles that perform specific functions.',
          },
          {
            'question': 'What is photosynthesis?',
            'answer': 'Photosynthesis is a process by which plants, algae, and some bacteria convert light energy, usually from the sun, into chemical energy in the form of glucose or other sugars.',
          },
          {
            'question': 'What is the equation for photosynthesis?',
            'answer': '6CO₂ + 6H₂O + light energy → C₆H₁₂O₆ (glucose) + 6O₂',
          },
          {
            'question': 'Where does photosynthesis occur in plant cells?',
            'answer': 'Photosynthesis occurs in the chloroplasts of plant cells, specifically in the grana and stroma of the chloroplasts.',
          },
        ];
        
        setState(() {
          _generatedFlashcards.clear();
          _generatedFlashcards.addAll(mockFlashcards);
          _isGenerating = false;
          _cardsGenerated = true;
        });
      });
    }
  }
  
  /// Save the deck
  void _saveDeck() {
    // TODO: Implement save to database
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Deck saved successfully!'),
      ),
    );
    
    Navigator.of(context).pop();
  }
}
