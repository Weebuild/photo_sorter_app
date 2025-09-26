import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';

void main() {
  runApp(const SchoolPhotoOrganizerApp());
}

class SchoolPhotoOrganizerApp extends StatelessWidget {
  const SchoolPhotoOrganizerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'School Photo Organizer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007AFF), // Apple blue
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7), // iOS background
        cardTheme: CardTheme(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Colors.white,
        ),
      ),
      home: const MainNavigationPage(),
    );
  }
}

class PhotoSorterHomePage extends StatefulWidget {
  const PhotoSorterHomePage({super.key});

  @override
  State<PhotoSorterHomePage> createState() => _PhotoSorterHomePageState();
}

class _PhotoSorterHomePageState extends State<PhotoSorterHomePage> {
  final List<String> _categories = ['Family', 'Travel', 'Work', 'Events', 'Others'];
  final ImagePicker _picker = ImagePicker();
  File? _currentPhoto;
  int _currentPhotoIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _openCamera() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _currentPhoto = File(photo.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo captured! Choose a category to sort it.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening camera: $e')),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      
      if (photo != null) {
        setState(() {
          _currentPhoto = File(photo.path);
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo selected! Choose a category to sort it.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting photo: $e')),
        );
      }
    }
  }

  void _sortPhoto(String category) {
    if (_currentPhoto != null) {
      // TODO: Implement actual photo sorting logic (save to category folder)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Photo sorted into $category category!')),
      );
      
      setState(() {
        _currentPhoto = null; // Clear current photo after sorting
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Photo Sorter'),
        elevation: 0,
      ),
      body: _currentPhoto == null ? _buildEmptyState() : _buildPhotoSortingInterface(),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _openCamera,
            tooltip: 'Take Photo',
            heroTag: "camera",
            child: const Icon(Icons.camera_alt),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _pickFromGallery,
            tooltip: 'Pick from Gallery',
            heroTag: "gallery",
            child: const Icon(Icons.photo_library),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Photo Sorter App',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a photo or pick from gallery to start sorting',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
          ),
          const SizedBox(height: 32),
          Text(
            'Available Categories:',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.grey[700],
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _categories.map((category) => Chip(
              label: Text(category),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSortingInterface() {
    return Column(
      children: [
        // Photo display
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _currentPhoto!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error, size: 50),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
        
        // Category selection
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Sort this photo into:',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 3,
                    ),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      return ElevatedButton(
                        onPressed: () => _sortPhoto(category),
                        style: ElevatedButton.styleFrom(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Clear photo button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() {
                        _currentPhoto = null;
                      });
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Photo'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
