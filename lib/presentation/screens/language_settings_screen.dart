import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashforge/config/app_config.dart';
import 'package:flashforge/l10n/app_localizations.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';

/// Provider for the current app locale
final localeProvider = StateProvider<Locale>((ref) {
  final languageCode = AppConfig.preferredLanguage;
  return Locale(languageCode, '');
});

/// Screen for language settings
class LanguageSettingsScreen extends ConsumerWidget {
  /// Default constructor
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('language')!),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Select your preferred language',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          ...AppConfig.supportedLanguages.map((languageCode) {
            final isSelected = currentLocale.languageCode == languageCode;
            
            return ListTile(
              title: Text(AppConfig.getLanguageName(languageCode)),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                ),
                child: Center(
                  child: Text(
                    languageCode.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
              trailing: isSelected 
                ? Icon(Icons.check_circle, color: AppTheme.primaryColor)
                : null,
              onTap: () async {
                // Update locale in provider
                ref.read(localeProvider.notifier).state = Locale(languageCode, '');
                
                // Save to local storage
                await AppConfig.setPreferredLanguage(languageCode);
                
                // Show confirmation
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language set to ${AppConfig.getLanguageName(languageCode)}'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            );
          }).toList(),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Note: Some changes might require restarting the app.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
