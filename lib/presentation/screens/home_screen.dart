import 'package:flutter/material.dart';
import 'package:flashforge/presentation/routes/app_router.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Home screen of the application
class HomeScreen extends StatefulWidget {
  /// Default constructor
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Current bottom navigation bar index
  int _currentIndex = 0;
  
  // Mock data for decks
  final List<Map<String, dynamic>> _mockDecks = [
    {
      'id': '1',
      'title': 'Biology 101',
      'description': 'Introduction to Cell Biology',
      'cardCount': 42,
      'progress': 0.65,
      'lastStudied': DateTime.now().subtract(const Duration(hours: 5)),
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
    },
    {
      'id': '2',
      'title': 'Spanish Vocabulary',
      'description': 'Basic Spanish words and phrases',
      'cardCount': 120,
      'progress': 0.3,
      'lastStudied': DateTime.now().subtract(const Duration(days: 2)),
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
    },
    {
      'id': '3',
      'title': 'Computer Science',
      'description': 'Algorithms and Data Structures',
      'cardCount': 85,
      'progress': 0.1,
      'lastStudied': DateTime.now().subtract(const Duration(days: 7)),
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('FlashForge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.settingsRoute);
            },
          ),
        ],
      ),
      
      // Floating action button to create new flashcards
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(AppRouter.createFlashcardRoute);
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
      
      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_stories),
            label: 'Decks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
        selectedItemColor: AppTheme.primaryColor,
      ),
      
      // Main content
      body: _buildCurrentView(),
    );
  }
  
  /// Build the current view based on the selected tab
  Widget _buildCurrentView() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeView();
      case 1:
        return _buildDecksView();
      case 2:
        return _buildStatsView();
      default:
        return _buildHomeView();
    }
  }
  
  /// Build the home view
  Widget _buildHomeView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome back!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Continue where you left off or create new flashcards.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // Daily streak card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Streak',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '5 days',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Continue studying section
          Text(
            'Continue Studying',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Deck cards
          if (_mockDecks.isNotEmpty)
            _buildDeckCard(_mockDecks[0])
          else
            _buildEmptyState(
              icon: Icons.auto_stories,
              message: 'No decks to study yet',
              buttonText: 'Create a Deck',
              onPressed: () {
                Navigator.of(context).pushNamed(AppRouter.createFlashcardRoute);
              },
            ),
          
          const SizedBox(height: 24),
          
          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Quick action buttons
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add,
                  label: 'New Deck',
                  onPressed: () {
                    Navigator.of(context).pushNamed(AppRouter.createFlashcardRoute);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.camera_alt,
                  label: 'Scan Notes',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon!'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.share,
                  label: 'Share Deck',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Coming soon!'),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Build the decks view
  Widget _buildDecksView() {
    return _mockDecks.isEmpty
        ? _buildEmptyState(
            icon: Icons.auto_stories,
            message: 'No decks yet',
            buttonText: 'Create a Deck',
            onPressed: () {
              Navigator.of(context).pushNamed(AppRouter.createFlashcardRoute);
            },
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _mockDecks.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildDeckCard(_mockDecks[index]),
              );
            },
          );
  }
  
  /// Build the stats view
  Widget _buildStatsView() {
    return Center(
      child: _buildEmptyState(
        icon: Icons.bar_chart,
        message: 'No statistics available yet',
        buttonText: 'Start Studying',
        onPressed: () {
          if (_mockDecks.isNotEmpty) {
            Navigator.of(context).pushNamed(
              AppRouter.studyRoute,
              arguments: {
                'deckId': _mockDecks[0]['id'],
              },
            );
          } else {
            Navigator.of(context).pushNamed(AppRouter.createFlashcardRoute);
          }
        },
      ),
    );
  }
  
  /// Build a deck card
  Widget _buildDeckCard(Map<String, dynamic> deck) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            AppRouter.deckDetailRoute,
            arguments: {
              'deckId': deck['id'],
            },
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      deck['title'],
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed(
                        AppRouter.studyRoute,
                        arguments: {
                          'deckId': deck['id'],
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(60, 36),
                    ),
                    child: const Text('Study'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                deck['description'],
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.credit_card,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${deck['cardCount']} cards',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Last studied: ${_formatDate(deck['lastStudied'])}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: deck['progress'] ?? 0.0,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '${(deck['progress'] * 100).toInt()}% complete',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build a quick action button
  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build an empty state widget
  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 80,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
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
