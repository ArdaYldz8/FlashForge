import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashforge/config/app_config.dart';
import 'package:flashforge/data/providers/providers.dart';
import 'package:flashforge/l10n/app_localizations.dart';
import 'package:flashforge/presentation/screens/language_settings_screen.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Provider for theme mode
final themeModeProvider = StateProvider<ThemeMode>((ref) {
  final mode = AppConfig.themeMode;
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
});

/// Settings screen
class SettingsScreen extends ConsumerStatefulWidget {
  /// Default constructor
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // API key
  final TextEditingController _apiKeyController = TextEditingController();
  
  // Language options
  final List<String> _languages = [
    'en', // English
    'es', // Spanish
    'tr', // Turkish
  ];
  
  // Notification settings
  bool _dailyReminders = true;
  bool _studySessionReminders = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize API key field
    _apiKeyController.text = AppConfig.huggingFaceApiToken ?? '';
  }
  
  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            _buildSectionHeader('Account'),
            _buildAccountSection(),
            
            const SizedBox(height: 24),
            
            // API Configuration section
            _buildSectionHeader('API Configuration'),
            _buildApiConfigSection(),
            
            const SizedBox(height: 24),
            
            // Appearance section
            _buildSectionHeader('Appearance'),
            _buildAppearanceSection(),
            
            const SizedBox(height: 24),
            
            // Language section
            _buildSectionHeader('Language'),
            _buildLanguageSection(),
            
            const SizedBox(height: 24),
            
            // Notifications section
            _buildSectionHeader('Notifications'),
            _buildNotificationsSection(),
            
            const SizedBox(height: 24),
            
            // About section
            _buildSectionHeader('About'),
            _buildAboutSection(),
            
            const SizedBox(height: 24),
            
            // Logout button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _logout,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a section header
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Build the account section
  Widget _buildAccountSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile picture and name
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: const Icon(
                    Icons.person,
                    size: 30,
                    color: AppTheme.primaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Name', // TODO: Replace with actual user name
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'user@example.com', // TODO: Replace with actual email
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // TODO: Implement edit profile
                  },
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Account settings options
            _buildSettingsItem(
              icon: Icons.cloud_sync,
              title: 'Sync Settings',
              subtitle: 'Manage data synchronization',
              onTap: () {
                // TODO: Implement sync settings
              },
            ),
            _buildSettingsItem(
              icon: Icons.security,
              title: 'Privacy',
              subtitle: 'Manage permissions and data',
              onTap: () {
                // TODO: Implement privacy settings
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the API configuration section
  Widget _buildApiConfigSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hugging Face API Key',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _apiKeyController,
              decoration: InputDecoration(
                hintText: 'Enter your Hugging Face API key',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveApiKey,
                ),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            Text(
              'Get your API key from huggingface.co/settings/tokens',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildSettingsItem(
              icon: Icons.model_training,
              title: 'AI Model Configuration',
              subtitle: 'Configure AI models used for flashcard generation',
              onTap: () {
                // TODO: Implement AI model configuration
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the appearance section
  Widget _buildAppearanceSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Theme options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildThemeOption(
                  label: 'Light',
                  icon: Icons.light_mode,
                  themeMode: ThemeMode.light,
                ),
                _buildThemeOption(
                  label: 'Dark',
                  icon: Icons.dark_mode,
                  themeMode: ThemeMode.dark,
                ),
                _buildThemeOption(
                  label: 'System',
                  icon: Icons.settings_brightness,
                  themeMode: ThemeMode.system,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the language section
  Widget _buildLanguageSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Language',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            
            // Language dropdown
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
          ],
        ),
      ),
    );
  }
  
  /// Build the notifications section
  Widget _buildNotificationsSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Daily Reminders'),
              subtitle: const Text('Remind you to study every day'),
              value: _dailyReminders,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  _dailyReminders = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Study Session Reminders'),
              subtitle: const Text('Remind you when cards are due for review'),
              value: _studySessionReminders,
              activeColor: AppTheme.primaryColor,
              onChanged: (value) {
                setState(() {
                  _studySessionReminders = value;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the about section
  Widget _buildAboutSection() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildSettingsItem(
              icon: Icons.info_outline,
              title: 'About FlashForge',
              subtitle: 'Version 1.0.0',
              onTap: () {
                // TODO: Implement about screen
              },
            ),
            _buildSettingsItem(
              icon: Icons.integration_instructions,
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              onTap: () {
                // TODO: Implement terms of service
              },
            ),
            _buildSettingsItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () {
                // TODO: Implement privacy policy
              },
            ),
            _buildSettingsItem(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'Get help and contact support',
              onTap: () {
                // TODO: Implement help and support
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a settings item
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppTheme.primaryColor,
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      trailing: const Icon(Icons.chevron_right),
    );
  }
  
  /// Build a theme option
  Widget _buildThemeOption({
    required String label,
    required IconData icon,
    required ThemeMode themeMode,
  }) {
    final isSelected = _themeMode == themeMode;
    
    return InkWell(
      onTap: () {
        setState(() {
          _themeMode = themeMode;
        });
        
        // TODO: Actually change the theme
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppTheme.primaryColor
                  : Colors.grey.shade600,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppTheme.primaryColor
                    : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Save the API key
  void _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    if (apiKey.isNotEmpty) {
      await AppConfig.setHuggingFaceApiToken(apiKey);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('API key saved successfully'),
          ),
        );
      }
    }
  }
  
  /// Logout the user
  void _logout() {
    // TODO: Implement logout functionality
    
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
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
              
              // TODO: Actually logout
              
              // Go back to home screen
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
