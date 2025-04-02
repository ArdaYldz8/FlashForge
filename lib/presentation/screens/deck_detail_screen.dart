import 'package:flutter/material.dart';
import 'package:flashforge/presentation/routes/app_router.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Screen to display deck details
class DeckDetailScreen extends StatefulWidget {
  /// ID of the deck to display
  final String deckId;
  
  /// Default constructor
  const DeckDetailScreen({
    Key? key,
    required this.deckId,
  }) : super(key: key);

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  // Mock deck data
  late Map<String, dynamic> _mockDeck;
  
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
  
  @override
  void initState() {
    super.initState();
    
    // Initialize mock deck data based on ID
    _mockDeck = {
      'id': widget.deckId,
      'title': 'Biology 101',
      'description': 'Introduction to Cell Biology',
      'cardCount': _mockFlashcards.length,
      'progress': 0.65,
      'lastStudied': DateTime.now().subtract(const Duration(hours: 5)),
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text(_mockDeck['title']),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                // TODO: Implement edit functionality
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              } else if (value == 'share') {
                // TODO: Implement share functionality
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit Deck'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Row(
                  children: [
                    Icon(Icons.share),
                    SizedBox(width: 8),
                    Text('Share Deck'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete Deck', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      
      // Study button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).pushNamed(
            AppRouter.studyRoute,
            arguments: {
              'deckId': widget.deckId,
            },
          );
        },
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.play_arrow),
        label: const Text('Study Now'),
      ),
      
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Deck info card
            _buildDeckInfoCard(),
            
            // Tabs for flashcards and statistics
            _buildTabContent(),
          ],
        ),
      ),
    );
  }
  
  /// Build the deck info card
  Widget _buildDeckInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _mockDeck['title'],
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _mockDeck['description'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatCard(
                  icon: Icons.credit_card,
                  value: '${_mockDeck['cardCount']}',
                  label: 'Cards',
                ),
                _buildStatCard(
                  icon: Icons.trending_up,
                  value: '${(_mockDeck['progress'] * 100).toInt()}%',
                  label: 'Mastery',
                ),
                _buildStatCard(
                  icon: Icons.calendar_today,
                  value: _formatDate(_mockDeck['lastStudied']),
                  label: 'Last Studied',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Progress',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _mockDeck['progress'] ?? 0.0,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the tab content
  Widget _buildTabContent() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(text: 'Flashcards'),
              Tab(text: 'Statistics'),
            ],
            labelColor: AppTheme.primaryColor,
            indicatorColor: AppTheme.primaryColor,
          ),
          SizedBox(
            height: 500, // Fixed height for the tab content
            child: TabBarView(
              children: [
                _buildFlashcardsTab(),
                _buildStatisticsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the flashcards tab
  Widget _buildFlashcardsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mockFlashcards.length,
      itemBuilder: (context, index) {
        return _buildFlashcardItem(
          question: _mockFlashcards[index]['question'] ?? '',
          answer: _mockFlashcards[index]['answer'] ?? '',
          index: index,
        );
      },
    );
  }
  
  /// Build the statistics tab
  Widget _buildStatisticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Study Sessions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock chart
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text('Statistics chart coming soon!'),
            ),
          ),
          const SizedBox(height: 24),
          
          Text(
            'Learning Insights',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Mock insights
          _buildInsightItem(
            icon: Icons.trending_up,
            title: 'Strong Knowledge',
            description: 'You\'ve mastered 65% of this deck',
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildInsightItem(
            icon: Icons.history,
            title: 'Time to Review',
            description: 'Some cards haven\'t been studied in 7 days',
            color: Colors.orange,
          ),
        ],
      ),
    );
  }
  
  /// Build a stat card
  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
  
  /// Build a flashcard item
  Widget _buildFlashcardItem({
    required String question,
    required String answer,
    required int index,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ExpansionTile(
        title: Text(question),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.all(16),
        children: [
          Text(
            'Answer:',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(answer),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // TODO: Implement edit functionality
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build an insight item
  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Show delete confirmation dialog
  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deck'),
        content: const Text('Are you sure you want to delete this deck? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              
              // Show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Deck deleted successfully'),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  /// Format a date to a readable string
  String _formatDate(DateTime? date) {
    if (date == null) return 'Never';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
