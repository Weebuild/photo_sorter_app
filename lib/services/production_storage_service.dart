import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import 'production_ai_classifier.dart';

/// Enhanced photo metadata with AI analysis
class PhotoMetadata {
  final String id;
  final String filePath;
  final String subject;
  final DateTime capturedAt;
  final double aiConfidence;
  final String detectedLanguage;
  final List<String> keywords;
  final String extractedText;
  final Map<String, double> subjectScores;

  PhotoMetadata({
    required this.id,
    required this.filePath,
    required this.subject,
    required this.capturedAt,
    required this.aiConfidence,
    required this.detectedLanguage,
    required this.keywords,
    required this.extractedText,
    required this.subjectScores,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'subject': subject,
    'capturedAt': capturedAt.toIso8601String(),
    'aiConfidence': aiConfidence,
    'detectedLanguage': detectedLanguage,
    'keywords': keywords,
    'extractedText': extractedText,
    'subjectScores': subjectScores,
  };

  factory PhotoMetadata.fromJson(Map<String, dynamic> json) => PhotoMetadata(
    id: json['id'],
    filePath: json['filePath'],
    subject: json['subject'],
    capturedAt: DateTime.parse(json['capturedAt']),
    aiConfidence: json['aiConfidence']?.toDouble() ?? 0.0,
    detectedLanguage: json['detectedLanguage'] ?? 'unknown',
    keywords: List<String>.from(json['keywords'] ?? []),
    extractedText: json['extractedText'] ?? '',
    subjectScores: Map<String, double>.from(json['subjectScores'] ?? {}),
  );
}

/// Enhanced subject folder with better organization
class EnhancedSubjectFolder {
  final String id;
  final String name;
  final String icon;
  final Color color;
  final List<PhotoMetadata> photos;
  final DateTime createdAt;
  final DateTime lastUpdated;

  EnhancedSubjectFolder({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.photos,
    required this.createdAt,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color.value,
    'photos': photos.map((p) => p.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory EnhancedSubjectFolder.fromJson(Map<String, dynamic> json) => EnhancedSubjectFolder(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    color: Color(json['color']),
    photos: (json['photos'] as List).map((p) => PhotoMetadata.fromJson(p)).toList(),
    createdAt: DateTime.parse(json['createdAt']),
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );

  /// Get photos by date range
  List<PhotoMetadata> getPhotosByDateRange(DateTime start, DateTime end) {
    return photos.where((photo) {
      return photo.capturedAt.isAfter(start) && photo.capturedAt.isBefore(end);
    }).toList();
  }

  /// Search photos by keywords
  List<PhotoMetadata> searchPhotos(String query) {
    final searchTerms = query.toLowerCase().split(' ');
    return photos.where((photo) {
      final searchableText = '${photo.extractedText} ${photo.keywords.join(' ')}'.toLowerCase();
      return searchTerms.any((term) => searchableText.contains(term));
    }).toList();
  }
}

/// Production-ready storage service with enhanced features
class ProductionStorageService {
  static const String _foldersKey = 'enhanced_subject_folders';
  static const String _searchIndexKey = 'search_index';
  static SharedPreferences? _prefs;

  // Subject color and icon mapping
  static const Map<String, Map<String, dynamic>> _subjectConfig = {
    'Mathematics': {'icon': '📐', 'color': 0xFF007AFF},
    'Biology': {'icon': '🧬', 'color': 0xFF34C759},
    'Chemistry': {'icon': '⚗️', 'color': 0xFFFF9500},
    'Physics': {'icon': '⚛️', 'color': 0xFF5856D6},
    'History': {'icon': '📜', 'color': 0xFFFF3B30},
    'Geography': {'icon': '🌍', 'color': 0xFF32D74B},
    'Literature': {'icon': '📚', 'color': 0xFF8E4EC6},
    'Art': {'icon': '🎨', 'color': 0xFFFF2D92},
    'Music': {'icon': '🎵', 'color': 0xFFFF6B35},
    'Computer Science': {'icon': '💻', 'color': 0xFF007AFF},
    'General': {'icon': '📁', 'color': 0xFF8E8E93},
  };

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Save photo with AI analysis
  static Future<PhotoMetadata> savePhotoWithAI(File photoFile) async {
    await init();
    
    try {
      // Perform AI analysis
      final aiResult = await ProductionAIClassifier.classifyImage(photoFile);
      
      // Create unique ID and save file
      final photoId = DateTime.now().millisecondsSinceEpoch.toString();
      final savedPhotoPath = await _savePhotoFile(photoFile, aiResult.subject, photoId);
      
      // Create photo metadata
      final photoMetadata = PhotoMetadata(
        id: photoId,
        filePath: savedPhotoPath,
        subject: aiResult.subject,
        capturedAt: DateTime.now(),
        aiConfidence: aiResult.confidence,
        detectedLanguage: aiResult.detectedLanguage,
        keywords: aiResult.educationalKeywords,
        extractedText: aiResult.extractedText,
        subjectScores: aiResult.subjectScores,
      );

      // Update folders
      await _addPhotoToFolder(photoMetadata);
      
      // Update search index
      await _updateSearchIndex(photoMetadata);

      return photoMetadata;

    } catch (e) {
      print('Error saving photo with AI: $e');
      rethrow;
    }
  }

  /// Save photo file to organized directory structure
  static Future<String> _savePhotoFile(File photo, String subject, String photoId) async {
    final directory = await getApplicationDocumentsDirectory();
    final subjectDir = Directory('${directory.path}/photos/$subject');
    
    if (!await subjectDir.exists()) {
      await subjectDir.create(recursive: true);
    }
    
    final fileName = '${photoId}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.jpg';
    final savedPhoto = await photo.copy('${subjectDir.path}/$fileName');
    return savedPhoto.path;
  }

  /// Add photo to appropriate folder
  static Future<void> _addPhotoToFolder(PhotoMetadata photoMetadata) async {
    final folders = await getFolders();
    
    // Find existing folder or create new one
    EnhancedSubjectFolder? targetFolder;
    for (final folder in folders) {
      if (folder.name == photoMetadata.subject) {
        targetFolder = folder;
        break;
      }
    }

    if (targetFolder == null) {
      // Create new folder
      final config = _subjectConfig[photoMetadata.subject] ?? _subjectConfig['General']!;
      targetFolder = EnhancedSubjectFolder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: photoMetadata.subject,
        icon: config['icon'],
        color: Color(config['color']),
        photos: [photoMetadata],
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
      );
      folders.add(targetFolder);
    } else {
      // Update existing folder
      final updatedPhotos = [...targetFolder.photos, photoMetadata];
      targetFolder = EnhancedSubjectFolder(
        id: targetFolder.id,
        name: targetFolder.name,
        icon: targetFolder.icon,
        color: targetFolder.color,
        photos: updatedPhotos,
        createdAt: targetFolder.createdAt,
        lastUpdated: DateTime.now(),
      );
      
      final folderIndex = folders.indexWhere((f) => f.id == targetFolder!.id);
      folders[folderIndex] = targetFolder;
    }

    await saveFolders(folders);
  }

  /// Get all folders
  static Future<List<EnhancedSubjectFolder>> getFolders() async {
    await init();
    final foldersJson = _prefs!.getStringList(_foldersKey) ?? [];
    return foldersJson.map((json) => EnhancedSubjectFolder.fromJson(jsonDecode(json))).toList();
  }

  /// Save folders
  static Future<void> saveFolders(List<EnhancedSubjectFolder> folders) async {
    await init();
    final foldersJson = folders.map((folder) => jsonEncode(folder.toJson())).toList();
    await _prefs!.setStringList(_foldersKey, foldersJson);
  }

  /// Search photos across all folders
  static Future<List<PhotoMetadata>> searchPhotos(String query) async {
    final folders = await getFolders();
    final List<PhotoMetadata> allResults = [];
    
    for (final folder in folders) {
      allResults.addAll(folder.searchPhotos(query));
    }
    
    // Sort by AI confidence and date
    allResults.sort((a, b) {
      final confidenceCompare = b.aiConfidence.compareTo(a.aiConfidence);
      if (confidenceCompare != 0) return confidenceCompare;
      return b.capturedAt.compareTo(a.capturedAt);
    });
    
    return allResults;
  }

  /// Get photos by date range
  static Future<List<PhotoMetadata>> getPhotosByDate(DateTime date) async {
    final folders = await getFolders();
    final List<PhotoMetadata> dayPhotos = [];
    
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    for (final folder in folders) {
      dayPhotos.addAll(folder.getPhotosByDateRange(startOfDay, endOfDay));
    }
    
    dayPhotos.sort((a, b) => b.capturedAt.compareTo(a.capturedAt));
    return dayPhotos;
  }

  /// Delete photo with shake animation support
  static Future<bool> deletePhoto(String photoId) async {
    try {
      final folders = await getFolders();
      bool photoFound = false;
      
      for (int i = 0; i < folders.length; i++) {
        final folder = folders[i];
        final photoIndex = folder.photos.indexWhere((p) => p.id == photoId);
        
        if (photoIndex != -1) {
          photoFound = true;
          final photoToDelete = folder.photos[photoIndex];
          
          // Delete physical file
          final file = File(photoToDelete.filePath);
          if (await file.exists()) {
            await file.delete();
          }
          
          // Remove from folder
          final updatedPhotos = List<PhotoMetadata>.from(folder.photos);
          updatedPhotos.removeAt(photoIndex);
          
          if (updatedPhotos.isEmpty) {
            // Remove empty folder
            folders.removeAt(i);
          } else {
            // Update folder
            folders[i] = EnhancedSubjectFolder(
              id: folder.id,
              name: folder.name,
              icon: folder.icon,
              color: folder.color,
              photos: updatedPhotos,
              createdAt: folder.createdAt,
              lastUpdated: DateTime.now(),
            );
          }
          break;
        }
      }
      
      if (photoFound) {
        await saveFolders(folders);
        await _removeFromSearchIndex(photoId);
      }
      
      return photoFound;
    } catch (e) {
      print('Error deleting photo: $e');
      return false;
    }
  }

  /// Update search index for fast searching
  static Future<void> _updateSearchIndex(PhotoMetadata photo) async {
    await init();
    final searchIndex = _prefs!.getStringList(_searchIndexKey) ?? [];
    
    final indexEntry = jsonEncode({
      'id': photo.id,
      'subject': photo.subject,
      'keywords': photo.keywords,
      'text': photo.extractedText,
      'language': photo.detectedLanguage,
    });
    
    searchIndex.add(indexEntry);
    await _prefs!.setStringList(_searchIndexKey, searchIndex);
  }

  /// Remove from search index
  static Future<void> _removeFromSearchIndex(String photoId) async {
    await init();
    final searchIndex = _prefs!.getStringList(_searchIndexKey) ?? [];
    
    searchIndex.removeWhere((entry) {
      final data = jsonDecode(entry);
      return data['id'] == photoId;
    });
    
    await _prefs!.setStringList(_searchIndexKey, searchIndex);
  }

  /// Get statistics
  static Future<Map<String, dynamic>> getStatistics() async {
    final folders = await getFolders();
    int totalPhotos = 0;
    final Map<String, int> subjectCounts = {};
    final Map<String, int> languageCounts = {};
    
    for (final folder in folders) {
      totalPhotos += folder.photos.length;
      subjectCounts[folder.name] = folder.photos.length;
      
      for (final photo in folder.photos) {
        languageCounts[photo.detectedLanguage] = 
            (languageCounts[photo.detectedLanguage] ?? 0) + 1;
      }
    }
    
    return {
      'totalPhotos': totalPhotos,
      'totalFolders': folders.length,
      'subjectCounts': subjectCounts,
      'languageCounts': languageCounts,
      'lastUpdate': folders.isEmpty ? null : 
          folders.map((f) => f.lastUpdated).reduce((a, b) => a.isAfter(b) ? a : b),
    };
  }
}

/// Color extension for JSON serialization
extension ColorExtension on Color {
  static Color fromValue(int value) => Color(value);
}