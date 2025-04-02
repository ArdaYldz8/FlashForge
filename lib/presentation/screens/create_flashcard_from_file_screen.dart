import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flashforge/data/providers/providers.dart';
import 'package:flashforge/domain/models/flashcard_model.dart';
import 'package:flashforge/l10n/app_localizations.dart';
import 'package:flashforge/presentation/theme/app_theme.dart';
import 'package:flashforge/utils/file_utils.dart';
import 'package:flashforge/utils/analytics_service.dart';

/// Screen for creating flashcards from various file sources
class CreateFlashcardFromFileScreen extends ConsumerStatefulWidget {
  /// ID of the deck to add flashcards to
  final String deckId;

  /// Default constructor
  const CreateFlashcardFromFileScreen({
    Key? key,
    required this.deckId,
  }) : super(key: key);

  @override
  ConsumerState<CreateFlashcardFromFileScreen> createState() =>
      _CreateFlashcardFromFileScreenState();
}

class _CreateFlashcardFromFileScreenState
    extends ConsumerState<CreateFlashcardFromFileScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  
  File? _selectedFile;
  String? _selectedFileName;
  String _selectedSourceType = 'text'; // 'text', 'url', 'file', 'camera'
  bool _isGenerating = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  int _maxCards = 10;
  String? _errorMessage;
  
  @override
  void dispose() {
    _textController.dispose();
    _urlController.dispose();
    super.dispose();
  }
  
  /// Select a file from device or camera
  Future<void> _selectFile() async {
    setState(() {
      _errorMessage = null;
    });
    
    File? file;
    
    try {
      if (_selectedSourceType == 'camera') {
        file = await FileUtils.pickImageFromCamera();
      } else {
        file = await FileUtils.pickFile(
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif']
        );
      }
      
      if (file != null) {
        final fileSize = await file.length();
        final maxSize = 10 * 1024 * 1024; // 10 MB
        
        if (fileSize > maxSize) {
          setState(() {
            _errorMessage = AppLocalizations.of(context)?.fileTooLarge ?? 
                'File too large. Maximum size is 10 MB.';
          });
          return;
        }
        
        setState(() {
          _selectedFile = file;
          _selectedFileName = file.path.split('/').last;
          _uploadProgress = 0.0;
        });
        
        // Simulate upload progress for better UX
        setState(() {
          _isUploading = true;
        });
        
        for (int i = 1; i <= 10; i++) {
          await Future.delayed(const Duration(milliseconds: 100));
          setState(() {
            _uploadProgress = i / 10;
          });
        }
        
        setState(() {
          _isUploading = false;
          _uploadProgress = 1.0;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)?.filePickerError ?? 
            'Error selecting file. Please try again.';
      });
    }
  }

  Future<void> _generateFlashcards() async {
    if (!_validateInput()) {
      return;
    }

    setState(() {
      _isGenerating = true;
    });

    try {
      List<Flashcard> generatedCards = [];
      final aiService = ref.read(aiServiceProvider.notifier);

      switch (_selectedSourceType) {
        case 'text':
          generatedCards = await aiService.generateFlashcardsFromText(
            text: _textController.text,
            deckId: widget.deckId,
            maxCards: _maxCards,
          );
          break;
          
        case 'url':
          generatedCards = await aiService.generateFlashcardsFromUrl(
            url: _urlController.text,
            deckId: widget.deckId,
            maxCards: _maxCards,
          );
          break;
          
        case 'file':
          if (_selectedFile != null && FileUtils.isPdfFile(_selectedFile!.path)) {
            final pdfBytes = await _selectedFile!.readAsBytes();
            
            // Log file upload analytics
            await AnalyticsService.logFileUpload(
              fileType: 'pdf',
              fileSize: pdfBytes.length,
              purpose: 'flashcard_generation',
            );
            
            // Also log study activity
            await AnalyticsService.logStudyActivity(
              activity: 'generate_from_pdf',
              deckId: widget.deckId,
              durationSeconds: 0,
            );
            
            generatedCards = await aiService.generateFlashcardsFromPdf(
              pdfBytes: pdfBytes,
              deckId: widget.deckId,
              maxCards: _maxCards,
            );
          } else if (_selectedFile != null && FileUtils.isImageFile(_selectedFile!.path)) {
            final imageBytes = await _selectedFile!.readAsBytes();
            
            // Log file upload analytics
            await AnalyticsService.logFileUpload(
              fileType: FileUtils.getFileExtension(_selectedFile!.path),
              fileSize: imageBytes.length,
              purpose: 'flashcard_generation',
            );
            
            // Also log study activity
            await AnalyticsService.logStudyActivity(
              activity: 'generate_from_image',
              deckId: widget.deckId,
              durationSeconds: 0,
            );
            
            generatedCards = await aiService.generateFlashcardsFromImage(
              imageBytes: imageBytes,
              deckId: widget.deckId,
              maxCards: _maxCards,
            );
          }
          break;
          
        case 'camera':
          if (_selectedFile != null) {
            final imageBytes = await _selectedFile!.readAsBytes();
            
            // Log camera capture analytics
            await AnalyticsService.logFileUpload(
              fileType: 'camera_image',
              fileSize: imageBytes.length,
              purpose: 'flashcard_generation',
            );
            
            // Also log study activity
            await AnalyticsService.logStudyActivity(
              activity: 'generate_from_camera',
              deckId: widget.deckId,
              durationSeconds: 0,
            );
            
            generatedCards = await aiService.generateFlashcardsFromImage(
              imageBytes: imageBytes,
              deckId: widget.deckId,
              maxCards: _maxCards,
            );
          }
          break;
      }

      // Save generated flashcards to the repository
      if (generatedCards.isNotEmpty) {
        await ref.read(flashcardsProvider.notifier).addFlashcards(
              deckId: widget.deckId,
              flashcards: generatedCards,
            );

        // Update deck card count
        await ref.read(decksProvider.notifier).updateDeckCardCount(
              deckId: widget.deckId,
              cardCount: generatedCards.length,
            );

        if (mounted) {
          _showSuccessDialog(generatedCards.length);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating flashcards: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  bool _validateInput() {
    String? errorMessage;

    switch (_selectedSourceType) {
      case 'text':
        if (_textController.text.isEmpty) {
          errorMessage = 'Please enter text to generate flashcards';
        }
        break;
        
      case 'url':
        if (_urlController.text.isEmpty) {
          errorMessage = 'Please enter a URL to generate flashcards';
        } else if (!Uri.parse(_urlController.text).isAbsolute) {
          errorMessage = 'Please enter a valid URL';
        }
        break;
        
      case 'file':
      case 'camera':
        if (_selectedFile == null) {
          errorMessage = 'Please select a file to generate flashcards';
        }
        break;
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _pickFile() async {
    File? file = await FileUtils.pickFile(
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (file != null) {
      setState(() {
        _selectedFile = file;
        _selectedFileName = file.path.split('/').last;
      });
    }
  }

  Future<void> _pickFile() async {
    setState(() {
      _errorMessage = null;
    });
    
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });
      
      // Simulate initial upload delay
      await Future.delayed(const Duration(milliseconds: 300));
      
      final file = await FileUtils.pickFile(
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'gif']
      );
      
      if (file != null) {
        final fileSize = await file.length();
        final maxSize = 10 * 1024 * 1024; // 10 MB
        
        if (fileSize > maxSize) {
          setState(() {
            _isUploading = false;
            _errorMessage = AppLocalizations.of(context)?.fileTooLarge ?? 
                'File too large. Maximum size is 10 MB.';
          });
          return;
        }
        
        // Simulate upload progress for better UX
        for (int i = 1; i <= 10; i++) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = i / 10;
          });
          await Future.delayed(const Duration(milliseconds: 100));
        }
        
        if (!mounted) return;
        setState(() {
          _selectedFile = file;
          _selectedFileName = file.path.split('/').last;
          _selectedSourceType = 'file';
          _isUploading = false;
          _uploadProgress = 1.0;
        });
        
        // Log analytics for file selection
        await AnalyticsService.logEvent(
          eventName: 'file_selected',
          parameters: {
            'file_type': FileUtils.getFileExtension(file.path),
            'file_size': fileSize,
          },
        );
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error selecting file: ${e.toString()}';
      });
    }
  }

  Future<void> _takePicture() async {
    setState(() {
      _errorMessage = null;
      _isUploading = true;
      _uploadProgress = 0.0;
    });
    
    try {
      final file = await FileUtils.pickImageFromCamera();

      if (file != null) {
        // Simulate upload progress for better UX
        for (int i = 1; i <= 10; i++) {
          if (!mounted) return;
          setState(() {
            _uploadProgress = i / 10;
          });
          await Future.delayed(const Duration(milliseconds: 70));
        }
        
        final fileSize = await file.length();
        
        setState(() {
          _selectedFile = file;
          _selectedFileName = 'Camera Image';
          _selectedSourceType = 'camera';
          _isUploading = false;
          _uploadProgress = 1.0;
        });
        
        // Log analytics for camera capture
        await AnalyticsService.logEvent(
          eventName: 'camera_image_captured',
          parameters: {
            'image_size': fileSize,
          },
        );
      } else {
        setState(() {
          _isUploading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _errorMessage = 'Error capturing image: ${e.toString()}';
      });
    }
  }

  void _showSuccessDialog(int cardCount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success!'),
        content: Text('Generated $cardCount flashcards successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Return to previous screen
            },
            child: const Text('Study Now'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Create More'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).translate('generate_cards')!),
      ),
      body: _isGenerating
          ? _buildLoadingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display error message if any
                  if (_errorMessage != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8.0),
                          Expanded(child: Text(_errorMessage!, style: TextStyle(color: Colors.red[700]))),
                        ],
                      ),
                    ),
                  
                  // Display upload progress if uploading
                  if (_isUploading)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Uploading file...',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8.0),
                          LinearProgressIndicator(value: _uploadProgress),
                          const SizedBox(height: 4.0),
                          Text(
                            '${(_uploadProgress * 100).toStringAsFixed(0)}%',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  _buildSourceSelector(),
                  const SizedBox(height: 24.0),
                  _buildSourceInput(),
                  const SizedBox(height: 24.0),
                  _buildMaxCardsSelector(),
                  const SizedBox(height: 32.0),
                  _buildGenerateButton(),
                  const SizedBox(height: 16.0),
                  _buildInfoCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16.0),
          Text(
            AppLocalizations.of(context).translate('generating')!,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8.0),
          Text(
            'This may take a moment...',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSourceSelector() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Source',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16.0),
            Wrap(
              spacing: 12.0,
              runSpacing: 12.0,
              children: [
                _buildSourceOption(
                  label: 'Text',
                  icon: Icons.text_fields,
                  value: 'text',
                ),
                _buildSourceOption(
                  label: 'URL',
                  icon: Icons.link,
                  value: 'url',
                ),
                _buildSourceOption(
                  label: 'File',
                  icon: Icons.upload_file,
                  value: 'file',
                ),
                _buildSourceOption(
                  label: 'Camera',
                  icon: Icons.camera_alt,
                  value: 'camera',
                  onTap: () {
                    _takePicture();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required String label,
    required IconData icon,
    required String value,
    VoidCallback? onTap,
  }) {
    final isSelected = _selectedSourceType == value;

    return GestureDetector(
      onTap: onTap ??
          () {
            setState(() {
              _selectedSourceType = value;
              if (value == 'camera') {
                _takePicture();
              }
            });
          },
      child: Container(
        width: 75,
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceInput() {
    switch (_selectedSourceType) {
      case 'text':
        return _buildTextInput();
      case 'url':
        return _buildUrlInput();
      case 'file':
      case 'camera':
        return _buildFileInput();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTextInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter Text',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _textController,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: 'Paste your text here...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Enter URL',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        TextField(
          controller: _urlController,
          decoration: InputDecoration(
            hintText: 'https://example.com',
            prefixIcon: const Icon(Icons.link),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildFileInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _selectedSourceType == 'file' ? 'Select File' : 'Camera Image',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        GestureDetector(
          onTap: _isUploading ? null : (_selectedSourceType == 'file' ? _pickFile : _takePicture),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: _selectedFile != null
                ? Column(
                    children: [
                      if (FileUtils.isImageFile(_selectedFile!.path))
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            _selectedFile!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (!FileUtils.isImageFile(_selectedFile!.path))
                        Icon(
                          FileUtils.getFileTypeIcon(_selectedFile!.path),
                          size: 64,
                          color: Colors.blue,
                        ),
                      const SizedBox(height: 8.0),
                      Text(
                        _selectedFileName ?? _selectedFile!.path.split('/').last,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8.0),
                      OutlinedButton.icon(
                        onPressed: _selectedSourceType == 'file'
                            ? _pickFile
                            : _takePicture,
                        icon: const Icon(Icons.refresh),
                        label: Text(_selectedSourceType == 'file'
                            ? 'Change File'
                            : 'Retake Photo'),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Icon(
                        _selectedSourceType == 'file'
                            ? Icons.upload_file
                            : Icons.camera_alt,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        _selectedSourceType == 'file'
                            ? 'Tap to select a file (PDF, image)'
                            : 'Tap to take a photo',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey.shade700,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMaxCardsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Number of Flashcards',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8.0),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: _maxCards.toDouble(),
                min: 5,
                max: 30,
                divisions: 25,
                label: _maxCards.toString(),
                onChanged: (value) {
                  setState(() {
                    _maxCards = value.toInt();
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                _maxCards.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isGenerating || _isUploading ? null : _generateFlashcards,
        icon: const Icon(Icons.auto_awesome),
        label: Text(
          AppLocalizations.of(context).translate('generate_cards')!,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 0,
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.blue),
                const SizedBox(width: 8.0),
                Text(
                  'How It Works',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            Text(
              'FlashForge uses AI to extract key concepts from your content and '
              'generate flashcards automatically. The quality of flashcards '
              'depends on the quality and relevance of your input.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade800,
                  ),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tip: For best results with PDF or image uploads, ensure the text '
              'is clearly visible and readable.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: Colors.blue.shade800,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
