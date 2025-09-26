import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

// Import our production AI services
import '../services/production_ai_classifier.dart';
import '../services/production_storage_service.dart';

// Compatibility class for UI
class ClassificationResult {
  final String subject;
  final double confidence;
  final String detectedLanguage;
  final String extractedText;
  final List<String> educationalKeywords;
  final Map<String, double> subjectScores;

  ClassificationResult({
    required this.subject,
    required this.confidence,
    required this.detectedLanguage,
    required this.extractedText,
    required this.educationalKeywords,
    required this.subjectScores,
  });

  // Getter for compatibility
  List<String> get tags => educationalKeywords;
}

// Helper function to convert AI result
ClassificationResult AIClassificationResult({
  required String subject,
  required double confidence,
  required String detectedLanguage,
  required String extractedText,
  required List<String> educationalKeywords,
  required Map<String, double> subjectScores,
}) {
  return ClassificationResult(
    subject: subject,
    confidence: confidence,
    detectedLanguage: detectedLanguage,
    extractedText: extractedText,
    educationalKeywords: educationalKeywords,
    subjectScores: subjectScores,
  );
}

// AI-Enhanced Home Page
class AIHomePage extends StatefulWidget {
  const AIHomePage({super.key});

  @override
  State<AIHomePage> createState() => _AIHomePageState();
}

class _AIHomePageState extends State<AIHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Photo Organizer',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Smart educational photo management',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 32),
              
              // Quick Actions
              Text(
                'Quick Actions',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              
              // Action Cards
              GestureDetector(
                onTap: () => _showCameraOptions(context),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF007AFF).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Capture with AI',
                                style: GoogleFonts.inter(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Smart analysis & organization →',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // AI Features Info
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'AI Features',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '• Real OCR text recognition\n• English & Swedish support\n• Smart subject classification\n• Content-based search\n• Automatic organization',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text(
          'Add Photo with AI Analysis',
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        message: Text(
          'Your photo will be automatically analyzed and organized',
          style: GoogleFonts.inter(fontSize: 14),
        ),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const AICameraPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt, color: Color(0xFF007AFF)),
                const SizedBox(width: 8),
                Text(
                  'Take Photo',
                  style: GoogleFonts.inter(color: const Color(0xFF007AFF)),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const AIGalleryPickerPage()),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.photo_library, color: Color(0xFF007AFF)),
                const SizedBox(width: 8),
                Text(
                  'Choose from Gallery',
                  style: GoogleFonts.inter(color: const Color(0xFF007AFF)),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: GoogleFonts.inter(color: const Color(0xFF007AFF), fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// AI Folders Page
class AIFoldersPage extends StatelessWidget {
  const AIFoldersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Subject Folders',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Automatically organized by AI',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E8E93).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 64,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'No folders yet',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Take photos to see AI-powered\nautomatic organization in action',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AI Calendar Page
class AICalendarPage extends StatelessWidget {
  const AICalendarPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Photo Calendar',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse photos by date',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8E8E93).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          size: 64,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Calendar View',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Coming soon - view your photos\norganized by date',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AI Search Page
class AISearchPage extends StatelessWidget {
  const AISearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Search',
                style: GoogleFonts.inter(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Search by content in English & Swedish',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 32),
              
              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search "matte ekvation" or "cell biology"...',
                    hintStyle: GoogleFonts.inter(
                      color: const Color(0xFF8E8E93),
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF8E8E93),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: GoogleFonts.inter(fontSize: 16),
                ),
              ),
              
              const SizedBox(height: 32),
              
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Icon(
                          Icons.search,
                          size: 64,
                          color: Color(0xFF007AFF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'AI-Powered Search',
                        style: GoogleFonts.inter(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search for mathematical equations,\nbiological diagrams, or any content\nin both English and Swedish',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: const Color(0xFF8E8E93),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// AI Camera Page
class AICameraPage extends StatefulWidget {
  const AICameraPage({super.key});

  @override
  State<AICameraPage> createState() => _AICameraPageState();
}

class _AICameraPageState extends State<AICameraPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _takePhoto();
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (photo != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (_) => AIPhotoProcessingPage(photoFile: File(photo.path)),
            ),
          );
        }
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showError('Camera access denied. Please enable camera permissions in Settings.');
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CupertinoActivityIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}

// AI Gallery Picker Page
class AIGalleryPickerPage extends StatefulWidget {
  const AIGalleryPickerPage({super.key});

  @override
  State<AIGalleryPickerPage> createState() => _AIGalleryPickerPageState();
}

class _AIGalleryPickerPageState extends State<AIGalleryPickerPage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _pickPhoto();
  }

  Future<void> _pickPhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (photo != null) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (_) => AIPhotoProcessingPage(photoFile: File(photo.path)),
            ),
          );
        }
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showError('Gallery access denied. Please enable photo library permissions in Settings.');
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: CupertinoActivityIndicator(
          color: Colors.white,
        ),
      ),
    );
  }
}

// AI Photo Processing Page
class AIPhotoProcessingPage extends StatefulWidget {
  final File photoFile;

  const AIPhotoProcessingPage({super.key, required this.photoFile});

  @override
  State<AIPhotoProcessingPage> createState() => _AIPhotoProcessingPageState();
}

class _AIPhotoProcessingPageState extends State<AIPhotoProcessingPage> {
  ClassificationResult? _aiResult;
  bool _isProcessing = true;
  bool _isCreatingFolder = false;

  @override
  void initState() {
    super.initState();
    _processPhoto();
  }

  Future<void> _processPhoto() async {
    try {
      // Use production AI classification
      final result = await ProductionAIClassifier.classifyImage(widget.photoFile);
      
      setState(() {
        _aiResult = AIClassificationResult(
          subject: result.subject,
          confidence: result.confidence,
          detectedLanguage: result.detectedLanguage,
          extractedText: result.extractedText,
          educationalKeywords: result.educationalKeywords,
          subjectScores: result.subjectScores,
        );
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('AI analysis failed. Please try again.');
    }
  }

  Future<void> _savePhoto() async {
    if (_aiResult == null) return;

    setState(() {
      _isCreatingFolder = true;
    });

    try {
      // Save photo with production AI metadata
      await ProductionStorageService.savePhotoWithAI(widget.photoFile);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Show success message
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: const Text('Photo Saved!'),
            content: Text(
              'Classified as "${_aiResult!.subject}" with ${(_aiResult!.confidence * 100).toInt()}% confidence.\n\nDetected language: ${_aiResult!.detectedLanguage.toUpperCase()}',
            ),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context),
                child: const Text('Great!'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingFolder = false;
        });
        _showError('Failed to save photo. Please try again.');
      }
    }
  }

  void _showError(String message) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'AI Analysis',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  const SizedBox(width: 36),
                ],
              ),
            ),
            
            // Photo Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.file(
                    widget.photoFile,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // Analysis Result
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  if (_isProcessing) ...[
                    const CupertinoActivityIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Analyzing with AI...',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Detecting text, language, and subject',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ] else if (_aiResult != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF34C759),
                                size: 32,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Subject Detected',
                                      style: GoogleFonts.inter(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF34C759),
                                      ),
                                    ),
                                    Text(
                                      _aiResult!.subject,
                                      style: GoogleFonts.inter(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Confidence: ${(_aiResult!.confidence * 100).toInt()}%',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF8E8E93),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Language: ${_aiResult!.detectedLanguage.toUpperCase()}',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: const Color(0xFF8E8E93),
                                ),
                              ),
                            ],
                          ),
                          if (_aiResult!.tags.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: _aiResult!.tags.take(5).map((tag) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF007AFF).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  tag,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: const Color(0xFF007AFF),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: CupertinoButton(
                        color: const Color(0xFF007AFF),
                        borderRadius: BorderRadius.circular(12),
                        onPressed: _isCreatingFolder ? null : _savePhoto,
                        child: _isCreatingFolder
                            ? const CupertinoActivityIndicator(color: Colors.white)
                            : Text(
                                'Save to ${_aiResult!.subject} Folder',
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}