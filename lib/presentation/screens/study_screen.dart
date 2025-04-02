import 'package:flutter/material.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Screen for studying flashcards
class StudyScreen extends StatefulWidget {
  /// ID of the deck to study
  final String deckId;
  
  /// Default constructor
  const StudyScreen({
    Key? key,
    required this.deckId,
  }) : super(key: key);

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> with SingleTickerProviderStateMixin {
  // Animation controller for card flip
  late AnimationController _flipController;
  
  // Animation for card flip
  late Animation<double> _flipAnimation;
  
  // Whether the card is showing the answer
  bool _showingAnswer = false;
  
  // Current card index
  int _currentCardIndex = 0;
  
  // Mock flashcards
  final List<Map<String, String>> _mockFlashcards = [
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
  
  // Knowledge ratings for flashcards
  final Map<int, int> _knowledgeRatings = {};
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Create flip animation
    _flipAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 0.5)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50.0,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.5, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50.0,
      ),
    ]).animate(_flipController);
    
    // Listen for animation status changes
    _flipAnimation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _showingAnswer = !_showingAnswer;
        });
      }
    });
  }
  
  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Study'),
        actions: [
          // Settings button
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showStudySettings();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentCardIndex + 1) / _mockFlashcards.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          
          // Card counter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card ${_currentCardIndex + 1} of ${_mockFlashcards.length}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '5:32 min', // Mock study time
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Flashcard
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: AnimatedBuilder(
                animation: _flipAnimation,
                builder: (context, child) {
                  final transform = Matrix4.identity()
                    ..setEntry(3, 2, 0.001)
                    ..rotateX(_flipAnimation.value * 3.14);
                  
                  return Transform(
                    transform: transform,
                    alignment: Alignment.center,
                    child: _flipAnimation.value < 0.5
                        ? _buildCardFront()
                        : _buildCardBack(),
                  );
                },
              ),
            ),
          ),
          
          // Action buttons
          _showingAnswer
              ? _buildAnswerButtons()
              : _buildQuestionButtons(),
        ],
      ),
    );
  }
  
  /// Build the front side of the flashcard (question)
  Widget _buildCardFront() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.help_outline,
              size: 48,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Question',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _mockFlashcards[_currentCardIndex]['question'] ?? '',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              'Tap to reveal answer',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the back side of the flashcard (answer)
  Widget _buildCardBack() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppTheme.secondaryColor,
            ),
            const SizedBox(height: 24),
            Text(
              'Answer',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _mockFlashcards[_currentCardIndex]['answer'] ?? '',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Text(
              'How well did you know this?',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build buttons for the question side
  Widget _buildQuestionButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: _currentCardIndex > 0 ? _previousCard : null,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.black,
              disabledBackgroundColor: Colors.grey.shade100,
              disabledForegroundColor: Colors.grey,
            ),
          ),
          
          // Show answer button
          ElevatedButton(
            onPressed: _flipCard,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text('Show Answer'),
          ),
        ],
      ),
    );
  }
  
  /// Build buttons for the answer side
  Widget _buildAnswerButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Knowledge rating buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildRatingButton(
                label: 'Hard',
                color: Colors.red.shade400,
                rating: 1,
              ),
              _buildRatingButton(
                label: 'Medium',
                color: Colors.orange.shade400,
                rating: 3,
              ),
              _buildRatingButton(
                label: 'Easy',
                color: Colors.green.shade400,
                rating: 5,
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Next card button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLastCard() ? _finishStudy : _nextCard,
              icon: Icon(_isLastCard() ? Icons.check : Icons.arrow_forward),
              label: Text(_isLastCard() ? 'Finish' : 'Next Card'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a rating button
  Widget _buildRatingButton({
    required String label,
    required Color color,
    required int rating,
  }) {
    final isSelected = _knowledgeRatings[_currentCardIndex] == rating;
    
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _knowledgeRatings[_currentCardIndex] = rating;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey.shade200,
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 2 : 0,
        minimumSize: const Size(100, 40),
      ),
      child: Text(label),
    );
  }
  
  /// Flip the card
  void _flipCard() {
    if (_flipController.isAnimating) return;
    
    if (_flipController.status == AnimationStatus.dismissed) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
  }
  
  /// Go to the next card
  void _nextCard() {
    if (_currentCardIndex < _mockFlashcards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _showingAnswer = false;
        _flipController.reset();
      });
    } else {
      _finishStudy();
    }
  }
  
  /// Go to the previous card
  void _previousCard() {
    if (_currentCardIndex > 0) {
      setState(() {
        _currentCardIndex--;
        _showingAnswer = false;
        _flipController.reset();
      });
    }
  }
  
  /// Check if this is the last card
  bool _isLastCard() {
    return _currentCardIndex == _mockFlashcards.length - 1;
  }
  
  /// Finish the study session
  void _finishStudy() {
    // TODO: Implement saving study session results
    
    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Study Session Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.celebration,
              color: AppTheme.accentColor,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Great job!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You studied ${_mockFlashcards.length} cards',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            // Statistics
            _buildStatItem(
              icon: Icons.timeline,
              label: 'Time Spent',
              value: '5:32',
            ),
            const SizedBox(height: 8),
            _buildStatItem(
              icon: Icons.speed,
              label: 'Cards Per Minute',
              value: '2.7',
            ),
            const SizedBox(height: 8),
            _buildStatItem(
              icon: Icons.insights,
              label: 'Knowledge Rating',
              value: '3.8 / 5',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
  
  /// Build a statistic item
  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  /// Show study settings dialog
  void _showStudySettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Study Settings',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Shuffle cards
              ListTile(
                leading: const Icon(Icons.shuffle),
                title: const Text('Shuffle Cards'),
                trailing: Switch(
                  value: false,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    // TODO: Implement shuffle
                    Navigator.of(context).pop();
                  },
                ),
                contentPadding: EdgeInsets.zero,
              ),
              
              // Audio pronunciation
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('Audio Pronunciation'),
                trailing: Switch(
                  value: false,
                  activeColor: AppTheme.primaryColor,
                  onChanged: (value) {
                    // TODO: Implement audio
                    Navigator.of(context).pop();
                  },
                ),
                contentPadding: EdgeInsets.zero,
              ),
              
              // Reset progress
              ListTile(
                leading: const Icon(Icons.restart_alt),
                title: const Text('Reset Progress'),
                onTap: () {
                  Navigator.of(context).pop();
                  // TODO: Implement reset
                },
                contentPadding: EdgeInsets.zero,
              ),
              
              // Exit study session
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Exit Study Session'),
                onTap: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                },
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        );
      },
    );
  }
}
