import 'package:flutter/material.dart';
import 'package:flashforge/presentation/routes/app_router.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Onboarding screen to introduce the app features
class OnboardingScreen extends StatefulWidget {
  /// Default constructor
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Page controller for the onboarding slides
  final PageController _pageController = PageController();
  
  // Current page index
  int _currentPage = 0;
  
  // Onboarding data
  final List<Map<String, String>> _onboardingData = [
    {
      'title': 'AI-Powered Flashcards',
      'description': 'FlashForge uses AI to automatically generate flashcards from your notes, textbooks, or any study material.',
      'icon': 'auto_awesome',
    },
    {
      'title': 'Smart Learning',
      'description': 'Our spaced repetition system optimizes your study schedule based on your performance.',
      'icon': 'psychology',
    },
    {
      'title': 'Language Support',
      'description': 'Study in multiple languages including English, Spanish, and Turkish.',
      'icon': 'translate',
    },
    {
      'title': 'Offline Study',
      'description': 'Access your flashcards anytime, anywhere, even without an internet connection.',
      'icon': 'offline_bolt',
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => _goToHome(),
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            
            // Page view for onboarding slides
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildOnboardingPage(
                    title: _onboardingData[index]['title'] ?? '',
                    description: _onboardingData[index]['description'] ?? '',
                    iconName: _onboardingData[index]['icon'] ?? '',
                  );
                },
              ),
            ),
            
            // Page indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => _buildPageIndicator(index),
              ),
            ),
            
            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  _currentPage > 0
                      ? ElevatedButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text('Back'),
                        )
                      : const SizedBox(width: 80),
                  
                  // Next/Get Started button
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < _onboardingData.length - 1) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        _goToHome();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: Text(
                      _currentPage < _onboardingData.length - 1
                          ? 'Next'
                          : 'Get Started',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a single onboarding page
  Widget _buildOnboardingPage({
    required String title,
    required String description,
    required String iconName,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            _getIconData(iconName),
            size: 100,
            color: AppTheme.primaryColor,
          ),
          const SizedBox(height: 40),
          
          // Title
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// Build a page indicator dot
  Widget _buildPageIndicator(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? AppTheme.primaryColor
            : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
  
  /// Get icon data from string name
  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'psychology':
        return Icons.psychology;
      case 'translate':
        return Icons.translate;
      case 'offline_bolt':
        return Icons.offline_bolt;
      default:
        return Icons.circle;
    }
  }
  
  /// Navigate to home screen
  void _goToHome() {
    Navigator.of(context).pushReplacementNamed(AppRouter.homeRoute);
  }
}
