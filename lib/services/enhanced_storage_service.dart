import 'dart:io';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../services/real_ai_classifier.dart';

/// Enhanced storage service with AI classification and search capabilities
class EnhancedStorageService {
  static const String _foldersKey = 'ai_subject_folders';
  static const String _photoMetadataKey = 'photo_metadata';
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<List<AISubjectFolder>> getFolders() async {
    await init();
    final foldersJson = _prefs!.getStringList(_foldersKey) ?? [];
    return foldersJson
        .map((json) => AISubjectFolder.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> saveFolders(List<AISubjectFolder> folders) async {
    await init();
    final foldersJson = folders.map((folder) => jsonEncode(folder.toJson())).toList();
    await _prefs!.setStringList(_foldersKey, foldersJson);
  }

  /// Save photo with AI classification
  static Future<PhotoMetadata> savePhotoWithAI(File photo, {String? manualSubject}) async {
    // Classify image with AI
    final ClassificationResult aiResult = await RealAIClassifier.classifyImage(photo);
    final String subject = manualSubject ?? aiResult.subject;
    
    // Create directory structure
    final directory = await getApplicationDocumentsDirectory();
    final folderDir = Directory('${directory.path}/photos/$subject');
    if (!await folderDir.exists()) {
      await folderDir.create(recursive: true);
    }
    
    // Save photo with timestamp
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final String fileName = '${timestamp}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final File savedPhoto = await photo.copy('${folderDir.path}/$fileName');
    
    // Create metadata
    final PhotoMetadata metadata = PhotoMetadata(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      filePath: savedPhoto.path,
      subject: subject,
      tags: aiResult.tags,
      confidence: aiResult.confidence,
      detectedLanguage: aiResult.detectedLanguage,
      extractedText: aiResult.extractedText,
      createdAt: DateTime.now(),
      isManuallyClassified: manualSubject != null,
    );
    
    // Save metadata
    await _savePhotoMetadata(metadata);
    
    // Update or create folder
    await _updateFolderWithPhoto(metadata);
    
    return metadata;
  }

  static Future<void> _savePhotoMetadata(PhotoMetadata metadata) async {
    await init();
    final List<String> metadataList = _prefs!.getStringList(_photoMetadataKey) ?? [];
    metadataList.add(jsonEncode(metadata.toJson()));
    await _prefs!.setStringList(_photoMetadataKey, metadataList);
  }

  static Future<List<PhotoMetadata>> getAllPhotosMetadata() async {
    await init();
    final List<String> metadataList = _prefs!.getStringList(_photoMetadataKey) ?? [];
    return metadataList
        .map((json) => PhotoMetadata.fromJson(jsonDecode(json)))
        .toList();
  }

  static Future<void> _updateFolderWithPhoto(PhotoMetadata metadata) async {
    final List<AISubjectFolder> folders = await getFolders();
    
    // Find existing folder or create new one
    AISubjectFolder? existingFolder;
    int folderIndex = -1;
    
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].name == metadata.subject) {
        existingFolder = folders[i];
        folderIndex = i;
        break;
      }
    }
    
    if (existingFolder != null) {
      // Update existing folder
      final updatedPhotos = [...existingFolder.photos, metadata.filePath];
      final updatedTags = Set<String>.from([...existingFolder.allTags, ...metadata.tags]).toList();
      
      folders[folderIndex] = existingFolder.copyWith(
        photos: updatedPhotos,
        allTags: updatedTags,
        lastUpdated: DateTime.now(),
      );
    } else {
      // Create new folder
      final Map<String, dynamic> subjectInfo = _getSubjectInfo(metadata.subject);
      final newFolder = AISubjectFolder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: metadata.subject,
        icon: subjectInfo['icon'],
        color: subjectInfo['color'],
        photos: [metadata.filePath],
        allTags: metadata.tags,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        averageConfidence: metadata.confidence,
        detectedLanguages: [metadata.detectedLanguage],
      );
      folders.add(newFolder);
    }
    
    await saveFolders(folders);
  }

  /// Smart search across all photos using AI
  static Future<List<PhotoSearchResult>> searchPhotos(String query) async {
    final List<PhotoMetadata> allMetadata = await getAllPhotosMetadata();
    final List<PhotoSearchResult> results = [];
    
    final String normalizedQuery = query.toLowerCase();
    
    for (final PhotoMetadata metadata in allMetadata) {
      double relevanceScore = 0.0;
      final List<String> matchReasons = [];
      
      // Check subject match
      if (metadata.subject.toLowerCase().contains(normalizedQuery)) {
        relevanceScore += 10.0;
        matchReasons.add('Subject: ${metadata.subject}');
      }
      
      // Check tag matches
      for (final String tag in metadata.tags) {
        if (tag.toLowerCase().contains(normalizedQuery)) {
          relevanceScore += 5.0;
          matchReasons.add('Tag: $tag');
        }
      }
      
      // Check extracted text
      if (metadata.extractedText.toLowerCase().contains(normalizedQuery)) {
        relevanceScore += 8.0;
        matchReasons.add('Content match');
      }
      
      // Add to results if relevant
      if (relevanceScore > 0) {
        results.add(PhotoSearchResult(
          metadata: metadata,
          relevanceScore: relevanceScore,
          matchReasons: matchReasons,
        ));
      }
    }
    
    // Sort by relevance
    results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
    return results;
  }

  /// Get photos by date
  static Future<List<PhotoMetadata>> getPhotosByDate(DateTime date) async {
    final List<PhotoMetadata> allMetadata = await getAllPhotosMetadata();
    final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
    final String targetDate = dateFormat.format(date);
    
    return allMetadata.where((metadata) {
      final String photoDate = dateFormat.format(metadata.createdAt);
      return photoDate == targetDate;
    }).toList();
  }

  /// Delete photo and update folder
  static Future<void> deletePhoto(String photoId) async {
    final List<PhotoMetadata> allMetadata = await getAllPhotosMetadata();
    final PhotoMetadata? photoToDelete = allMetadata.firstWhereOrNull(
      (metadata) => metadata.id == photoId,
    );
    
    if (photoToDelete == null) return;
    
    // Delete physical file
    final File photoFile = File(photoToDelete.filePath);
    if (await photoFile.exists()) {
      await photoFile.delete();
    }
    
    // Remove from metadata
    allMetadata.removeWhere((metadata) => metadata.id == photoId);
    await init();
    final List<String> updatedMetadataList = allMetadata
        .map((metadata) => jsonEncode(metadata.toJson()))
        .toList();
    await _prefs!.setStringList(_photoMetadataKey, updatedMetadataList);
    
    // Update folder
    final List<AISubjectFolder> folders = await getFolders();
    for (int i = 0; i < folders.length; i++) {
      final AISubjectFolder folder = folders[i];
      if (folder.photos.contains(photoToDelete.filePath)) {
        final updatedPhotos = folder.photos.where((path) => path != photoToDelete.filePath).toList();
        
        if (updatedPhotos.isEmpty) {
          // Remove empty folder
          folders.removeAt(i);
        } else {
          // Update folder
          folders[i] = folder.copyWith(photos: updatedPhotos);
        }
        break;
      }
    }
    
    await saveFolders(folders);
  }

  /// Manually correct photo classification
  static Future<void> correctPhotoClassification(String photoId, String newSubject) async {
    final List<PhotoMetadata> allMetadata = await getAllPhotosMetadata();
    final int photoIndex = allMetadata.indexWhere((metadata) => metadata.id == photoId);
    
    if (photoIndex == -1) return;
    
    final PhotoMetadata oldMetadata = allMetadata[photoIndex];
    final String oldSubject = oldMetadata.subject;
    
    // Update metadata
    final PhotoMetadata updatedMetadata = oldMetadata.copyWith(
      subject: newSubject,
      isManuallyClassified: true,
    );
    allMetadata[photoIndex] = updatedMetadata;
    
    // Save updated metadata
    await init();
    final List<String> updatedMetadataList = allMetadata
        .map((metadata) => jsonEncode(metadata.toJson()))
        .toList();
    await _prefs!.setStringList(_photoMetadataKey, updatedMetadataList);
    
    // Move physical file
    await _movePhotoToNewFolder(oldMetadata.filePath, oldSubject, newSubject);
    
    // Update folders
    await _updateFoldersAfterCorrection(oldMetadata.filePath, oldSubject, newSubject);
  }

  static Future<void> _movePhotoToNewFolder(String filePath, String oldSubject, String newSubject) async {
    final File oldFile = File(filePath);
    if (!await oldFile.exists()) return;
    
    final directory = await getApplicationDocumentsDirectory();
    final newFolderDir = Directory('${directory.path}/photos/$newSubject');
    if (!await newFolderDir.exists()) {
      await newFolderDir.create(recursive: true);
    }
    
    final String fileName = filePath.split('/').last;
    final String newPath = '${newFolderDir.path}/$fileName';
    await oldFile.copy(newPath);
    await oldFile.delete();
  }

  static Future<void> _updateFoldersAfterCorrection(String photoPath, String oldSubject, String newSubject) async {
    final List<AISubjectFolder> folders = await getFolders();
    
    // Remove from old folder
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].name == oldSubject) {
        final updatedPhotos = folders[i].photos.where((path) => path != photoPath).toList();
        if (updatedPhotos.isEmpty) {
          folders.removeAt(i);
        } else {
          folders[i] = folders[i].copyWith(photos: updatedPhotos);
        }
        break;
      }
    }
    
    // Add to new folder or create it
    bool foundNewFolder = false;
    for (int i = 0; i < folders.length; i++) {
      if (folders[i].name == newSubject) {
        final updatedPhotos = [...folders[i].photos, photoPath];
        folders[i] = folders[i].copyWith(photos: updatedPhotos);
        foundNewFolder = true;
        break;
      }
    }
    
    if (!foundNewFolder) {
      final Map<String, dynamic> subjectInfo = _getSubjectInfo(newSubject);
      final newFolder = AISubjectFolder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: newSubject,
        icon: subjectInfo['icon'],
        color: subjectInfo['color'],
        photos: [photoPath],
        allTags: [],
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        averageConfidence: 0.5,
        detectedLanguages: ['unknown'],
      );
      folders.add(newFolder);
    }
    
    await saveFolders(folders);
  }

  static Map<String, dynamic> _getSubjectInfo(String subject) {
    final Map<String, Map<String, dynamic>> subjectDatabase = {
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
    };
    
    return subjectDatabase[subject] ?? {'icon': '📁', 'color': 0xFF8E8E93};
  }
}

/// Enhanced folder model with AI capabilities
class AISubjectFolder {
  final String id;
  final String name;
  final String icon;
  final int color;
  final List<String> photos;
  final List<String> allTags;
  final DateTime createdAt;
  final DateTime lastUpdated;
  final double averageConfidence;
  final List<String> detectedLanguages;

  const AISubjectFolder({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.photos,
    required this.allTags,
    required this.createdAt,
    required this.lastUpdated,
    required this.averageConfidence,
    required this.detectedLanguages,
  });

  AISubjectFolder copyWith({
    String? id,
    String? name,
    String? icon,
    int? color,
    List<String>? photos,
    List<String>? allTags,
    DateTime? createdAt,
    DateTime? lastUpdated,
    double? averageConfidence,
    List<String>? detectedLanguages,
  }) {
    return AISubjectFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      photos: photos ?? this.photos,
      allTags: allTags ?? this.allTags,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      averageConfidence: averageConfidence ?? this.averageConfidence,
      detectedLanguages: detectedLanguages ?? this.detectedLanguages,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'photos': photos,
    'allTags': allTags,
    'createdAt': createdAt.toIso8601String(),
    'lastUpdated': lastUpdated.toIso8601String(),
    'averageConfidence': averageConfidence,
    'detectedLanguages': detectedLanguages,
  };

  factory AISubjectFolder.fromJson(Map<String, dynamic> json) => AISubjectFolder(
    id: json['id'],
    name: json['name'],
    icon: json['icon'],
    color: json['color'],
    photos: List<String>.from(json['photos']),
    allTags: List<String>.from(json['allTags'] ?? []),
    createdAt: DateTime.parse(json['createdAt']),
    lastUpdated: DateTime.parse(json['lastUpdated']),
    averageConfidence: (json['averageConfidence'] ?? 0.0).toDouble(),
    detectedLanguages: List<String>.from(json['detectedLanguages'] ?? ['unknown']),
  );
}

/// Photo metadata with AI classification results
class PhotoMetadata {
  final String id;
  final String filePath;
  final String subject;
  final List<String> tags;
  final double confidence;
  final String detectedLanguage;
  final String extractedText;
  final DateTime createdAt;
  final bool isManuallyClassified;

  const PhotoMetadata({
    required this.id,
    required this.filePath,
    required this.subject,
    required this.tags,
    required this.confidence,
    required this.detectedLanguage,
    required this.extractedText,
    required this.createdAt,
    required this.isManuallyClassified,
  });

  PhotoMetadata copyWith({
    String? id,
    String? filePath,
    String? subject,
    List<String>? tags,
    double? confidence,
    String? detectedLanguage,
    String? extractedText,
    DateTime? createdAt,
    bool? isManuallyClassified,
  }) {
    return PhotoMetadata(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      extractedText: extractedText ?? this.extractedText,
      createdAt: createdAt ?? this.createdAt,
      isManuallyClassified: isManuallyClassified ?? this.isManuallyClassified,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'subject': subject,
    'tags': tags,
    'confidence': confidence,
    'detectedLanguage': detectedLanguage,
    'extractedText': extractedText,
    'createdAt': createdAt.toIso8601String(),
    'isManuallyClassified': isManuallyClassified,
  };

  factory PhotoMetadata.fromJson(Map<String, dynamic> json) => PhotoMetadata(
    id: json['id'],
    filePath: json['filePath'],
    subject: json['subject'],
    tags: List<String>.from(json['tags']),
    confidence: (json['confidence'] ?? 0.0).toDouble(),
    detectedLanguage: json['detectedLanguage'] ?? 'unknown',
    extractedText: json['extractedText'] ?? '',
    createdAt: DateTime.parse(json['createdAt']),
    isManuallyClassified: json['isManuallyClassified'] ?? false,
  );
}

/// Search result with relevance scoring
class PhotoSearchResult {
  final PhotoMetadata metadata;
  final double relevanceScore;
  final List<String> matchReasons;

  const PhotoSearchResult({
    required this.metadata,
    required this.relevanceScore,
    required this.matchReasons,
  });
}

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    try {
      return firstWhere(test);
    } catch (e) {
      return null;
    }
  }
}