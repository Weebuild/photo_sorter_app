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

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

// Import our AI services
import 'services/real_ai_classifier.dart';
import 'services/enhanced_storage_service.dart';

// Import AI pages
import 'widgets/ai_pages.dart';

void main() {
  runApp(const SchoolPhotoOrganizerApp());
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AISchoolPhotoOrganizerApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Photo Organizer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF007AFF)),
        useMaterial3: true,
        fontFamily: GoogleFonts.inter().fontFamily,
      ),
      home: const AIPhotoSorterHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Data Models
class SubjectFolder {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final List<String> photos;
  final DateTime createdAt;

  SubjectFolder({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.photos,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color.value,
    'photos': photos,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SubjectFolder.fromJson(Map<String, dynamic> json) => SubjectFolder(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    color: Color(json['color']),
    photos: List<String>.from(json['photos']),
    createdAt: DateTime.parse(json['createdAt']),
  );
}

// AI Subject Detection Service (Mock implementation)
class AISubjectDetector {
  static final Map<String, Map<String, dynamic>> _subjectDatabase = {
    'Mathematics': {'icon': '📐', 'color': Color(0xFF007AFF)},
    'Biology': {'icon': '🧬', 'color': Color(0xFF34C759)},
    'Chemistry': {'icon': '⚗️', 'color': Color(0xFFFF9500)},
    'Physics': {'icon': '⚛️', 'color': Color(0xFF5856D6)},
    'History': {'icon': '📜', 'color': Color(0xFFFF3B30)},
    'Geography': {'icon': '🌍', 'color': Color(0xFF32D74B)},
    'Literature': {'icon': '📚', 'color': Color(0xFF8E4EC6)},
    'Art': {'icon': '🎨', 'color': Color(0xFFFF2D92)},
    'Music': {'icon': '🎵', 'color': Color(0xFFFF6B35)},
    'Computer Science': {'icon': '💻', 'color': Color(0xFF007AFF)},
  };

  static Future<String> detectSubject(File imageFile) async {
    // Simulate AI processing time
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mock AI detection - randomly select a subject for demo
    final subjects = _subjectDatabase.keys.toList();
    final random = Random();
    return subjects[random.nextInt(subjects.length)];
  }

  static Map<String, dynamic> getSubjectInfo(String subject) {
    return _subjectDatabase[subject] ?? {'icon': '📁', 'color': Color(0xFF8E8E93)};
  }
}

// Storage Service
class StorageService {
  static const String _foldersKey = 'subject_folders';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<List<SubjectFolder>> getFolders() async {
    await init();
    final foldersJson = _prefs!.getStringList(_foldersKey) ?? [];
    return foldersJson.map((json) => SubjectFolder.fromJson(jsonDecode(json))).toList();
  }

  static Future<void> saveFolders(List<SubjectFolder> folders) async {
    await init();
    final foldersJson = folders.map((folder) => jsonEncode(folder.toJson())).toList();
    await _prefs!.setStringList(_foldersKey, foldersJson);
  }

  static Future<String> savePhoto(File photo, String folderId) async {
    final directory = await getApplicationDocumentsDirectory();
    final folderDir = Directory('${directory.path}/photos/$folderId');
    if (!await folderDir.exists()) {
      await folderDir.create(recursive: true);
    }
    
    final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final savedPhoto = await photo.copy('${folderDir.path}/$fileName');
    return savedPhoto.path;
  }
}

// AI-Enhanced Main Navigation Page
class AIMainNavigationPage extends StatefulWidget {
  const AIMainNavigationPage({super.key});

  @override
  State<AIMainNavigationPage> createState() => _AIMainNavigationPageState();
}

class _AIMainNavigationPageState extends State<AIMainNavigationPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: const [
          AIHomePage(),
          AIFoldersPage(),
          AICalendarPage(),
          AISearchPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_rounded, 'Home'),
                _buildNavItem(1, Icons.folder_rounded, 'Folders'),
                _buildNavItem(2, Icons.calendar_today_rounded, 'Calendar'),
                _buildNavItem(3, Icons.search_rounded, 'Search'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() {
          _currentIndex = index;
        });
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF007AFF).withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.inter(
                color: isSelected ? const Color(0xFF007AFF) : const Color(0xFF8E8E93),
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Home Page
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
              Text(
                'School Photos',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capture and organize class memories',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 40),
              
              // Action Cards
              Expanded(
                child: Column(
                  children: [
                    _buildActionCard(
                      context,
                      title: 'Take Photos',
                      subtitle: 'Start a new photo session →',
                      icon: Icons.camera_alt_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF007AFF), Color(0xFF5856D6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () => _showCameraOptions(context),
                    ),
                    const SizedBox(height: 20),
                    _buildActionCard(
                      context,
                      title: 'Photo Gallery',
                      subtitle: 'Browse photos by subject →',
                      icon: Icons.photo_library_rounded,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF34C759), Color(0xFF32D74B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      onTap: () {
                        // Switch to folders tab
                        final navigator = Navigator.of(context);
                        navigator.push(
                          MaterialPageRoute(
                            builder: (context) => const FoldersPage(),
                          ),
                        );
                      },
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

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCameraOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Add Photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const CameraPage()),
              );
            },
            child: const Text('Take Photo'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const GalleryPickerPage()),
              );
            },
            child: const Text('Choose from Gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

// Folders Page
class FoldersPage extends StatefulWidget {
  const FoldersPage({super.key});

  @override
  State<FoldersPage> createState() => _FoldersPageState();
}

class _FoldersPageState extends State<FoldersPage> {
  List<SubjectFolder> _folders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final folders = await StorageService.getFolders();
    setState(() {
      _folders = folders;
      _isLoading = false;
    });
  }

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
                'Subject Folders',
                style: GoogleFonts.inter(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_folders.length} ${_folders.length == 1 ? 'folder' : 'folders'} created',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  color: const Color(0xFF8E8E93),
                ),
              ),
              const SizedBox(height: 32),
              
              Expanded(
                child: _isLoading
                    ? const Center(child: CupertinoActivityIndicator())
                    : _folders.isEmpty
                        ? _buildEmptyState()
                        : _buildFoldersGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFF8E8E93).withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.folder_outlined,
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
            'Take photos to automatically create\nsubject folders with AI',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: const Color(0xFF8E8E93),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoldersGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: _folders.length,
      itemBuilder: (context, index) {
        final folder = _folders[index];
        return _buildFolderCard(folder);
      },
    );
  }

  Widget _buildFolderCard(SubjectFolder folder) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => PhotoGalleryPage(folder: folder),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: folder.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    folder.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                folder.name,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${folder.photos.length} ${folder.photos.length == 1 ? 'photo' : 'photos'}',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: const Color(0xFF8E8E93),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Camera Page
class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
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
              builder: (_) => PhotoProcessingPage(photoFile: File(photo.path)),
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

// Gallery Picker Page
class GalleryPickerPage extends StatefulWidget {
  const GalleryPickerPage({super.key});

  @override
  State<GalleryPickerPage> createState() => _GalleryPickerPageState();
}

class _GalleryPickerPageState extends State<GalleryPickerPage> {
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
              builder: (_) => PhotoProcessingPage(photoFile: File(photo.path)),
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

// Photo Processing Page
class PhotoProcessingPage extends StatefulWidget {
  final File photoFile;

  const PhotoProcessingPage({super.key, required this.photoFile});

  @override
  State<PhotoProcessingPage> createState() => _PhotoProcessingPageState();
}

class _PhotoProcessingPageState extends State<PhotoProcessingPage> {
  String? _detectedSubject;
  bool _isProcessing = true;
  bool _isCreatingFolder = false;

  @override
  void initState() {
    super.initState();
    _processPhoto();
  }

  Future<void> _processPhoto() async {
    // Simulate AI processing
    final subject = await AISubjectDetector.detectSubject(widget.photoFile);
    
    setState(() {
      _detectedSubject = subject;
      _isProcessing = false;
    });
  }

  Future<void> _savePhoto() async {
    if (_detectedSubject == null) return;

    setState(() {
      _isCreatingFolder = true;
    });

    try {
      // Get existing folders
      final folders = await StorageService.getFolders();
      
      // Check if folder exists for this subject
      SubjectFolder? existingFolder;
      for (final folder in folders) {
        if (folder.name == _detectedSubject) {
          existingFolder = folder;
          break;
        }
      }

      // Save photo to appropriate folder
      String folderId;
      if (existingFolder != null) {
        folderId = existingFolder.id;
      } else {
        // Create new folder
        final subjectInfo = AISubjectDetector.getSubjectInfo(_detectedSubject!);
        folderId = DateTime.now().millisecondsSinceEpoch.toString();
        
        final newFolder = SubjectFolder(
          id: folderId,
          name: _detectedSubject!,
          icon: subjectInfo['icon'],
          color: subjectInfo['color'],
          photos: [],
          createdAt: DateTime.now(),
        );
        
        folders.add(newFolder);
      }

      // Save photo file
      final photoPath = await StorageService.savePhoto(widget.photoFile, folderId);
      
      // Update folder with new photo
      final folderIndex = folders.indexWhere((f) => f.id == folderId);
      if (folderIndex != -1) {
        folders[folderIndex] = SubjectFolder(
          id: folders[folderIndex].id,
          name: folders[folderIndex].name,
          icon: folders[folderIndex].icon,
          color: folders[folderIndex].color,
          photos: [...folders[folderIndex].photos, photoPath],
          createdAt: folders[folderIndex].createdAt,
        );
      }

      // Save updated folders
      await StorageService.saveFolders(folders);

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
        
        // Show success message
        final isNewFolder = existingFolder == null;
        showCupertinoDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(isNewFolder ? 'New Folder Created!' : 'Photo Added!'),
            content: Text(
              isNewFolder 
                ? 'Created "$_detectedSubject" folder and added your photo.'
                : 'Added photo to "$_detectedSubject" folder.',
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
                        color: Colors.white.withOpacity(0.1),
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
                      color: Colors.black.withOpacity(0.3),
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
                      'Analyzing photo with AI...',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: const Color(0xFF8E8E93),
                      ),
                    ),
                  ] else if (_detectedSubject != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF34C759).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Text(
                            AISubjectDetector.getSubjectInfo(_detectedSubject!)['icon'],
                            style: const TextStyle(fontSize: 32),
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
                                  _detectedSubject!,
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
                                'Save to $_detectedSubject Folder',
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

// Photo Gallery Page
class PhotoGalleryPage extends StatelessWidget {
  final SubjectFolder folder;

  const PhotoGalleryPage({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
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
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: folder.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      folder.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          folder.name,
                          style: GoogleFonts.inter(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          '${folder.photos.length} ${folder.photos.length == 1 ? 'photo' : 'photos'}',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: const Color(0xFF8E8E93),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Photos Grid
            Expanded(
              child: folder.photos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: folder.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              folder.icon,
                              style: const TextStyle(fontSize: 64),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No photos yet',
                            style: GoogleFonts.inter(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Photos will appear here when you\ncapture ${folder.name.toLowerCase()} content',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              color: const Color(0xFF8E8E93),
                            ),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: folder.photos.length,
                        itemBuilder: (context, index) {
                          final photoPath = folder.photos[index];
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                File(photoPath),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(
                                        Icons.error_outline,
                                        size: 32,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
