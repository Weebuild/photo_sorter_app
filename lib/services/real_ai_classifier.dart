import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'package:collection/collection.dart';

/// Real AI-powered educational content classifier using Google ML Kit OCR
/// Supports English and Swedish text recognition for educational subjects
class RealAIClassifier {
  static final _textRecognizer = TextRecognizer();
  static final _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  
  // Educational keywords database for classification
  static final Map<String, Map<String, List<String>>> _educationalKeywords = {
    'Mathematics': {
      'en': [
        'equation', 'algebra', 'calculus', 'geometry', 'trigonometry',
        'integral', 'derivative', 'function', 'matrix', 'polynomial',
        'theorem', 'proof', 'formula', 'variable', 'coefficient',
        'logarithm', 'exponential', 'sin', 'cos', 'tan', 'limit',
        'infinity', 'pi', 'square root', 'fraction', 'ratio',
        'statistics', 'probability', 'mean', 'median', 'mode',
        'graph', 'plot', 'axis', 'coordinate', 'linear', 'quadratic'
      ],
      'sv': [
        'ekvation', 'algebra', 'kalkyl', 'geometri', 'trigonometri',
        'integral', 'derivata', 'funktion', 'matris', 'polynom',
        'sats', 'bevis', 'formel', 'variabel', 'koefficient',
        'logaritm', 'exponentiell', 'sin', 'cos', 'tan', 'gräns',
        'oändlighet', 'pi', 'kvadratrot', 'bråk', 'förhållande',
        'statistik', 'sannolikhet', 'medelvärde', 'median', 'typvärde',
        'graf', 'plot', 'axel', 'koordinat', 'linjär', 'kvadratisk',
        'matte', 'matematik', 'räkna', 'tal', 'siffra'
      ]
    },
    'Biology': {
      'en': [
        'cell', 'dna', 'rna', 'protein', 'enzyme', 'mitochondria',
        'chloroplast', 'nucleus', 'membrane', 'chromosome', 'gene',
        'evolution', 'species', 'organism', 'bacteria', 'virus',
        'photosynthesis', 'respiration', 'metabolism', 'homeostasis',
        'ecosystem', 'biodiversity', 'genetics', 'heredity', 'mutation',
        'natural selection', 'adaptation', 'reproduction', 'meiosis', 'mitosis',
        'tissue', 'organ', 'system', 'anatomy', 'physiology'
      ],
      'sv': [
        'cell', 'dna', 'rna', 'protein', 'enzym', 'mitokondrier',
        'kloroplast', 'kärna', 'membran', 'kromosom', 'gen',
        'evolution', 'art', 'organism', 'bakterie', 'virus',
        'fotosyntes', 'andning', 'ämnesomsättning', 'homeostas',
        'ekosystem', 'biodiversitet', 'genetik', 'ärftlighet', 'mutation',
        'naturligt urval', 'anpassning', 'fortplantning', 'meios', 'mitos',
        'vävnad', 'organ', 'system', 'anatomi', 'fysiologi',
        'biologi', 'liv', 'levande', 'natur'
      ]
    },
    'Chemistry': {
      'en': [
        'atom', 'molecule', 'element', 'compound', 'reaction', 'bond',
        'ionic', 'covalent', 'electron', 'proton', 'neutron',
        'periodic table', 'oxidation', 'reduction', 'acid', 'base',
        'ph', 'catalyst', 'equilibrium', 'enthalpy', 'entropy',
        'molarity', 'molality', 'stoichiometry', 'thermodynamics',
        'kinetics', 'organic', 'inorganic', 'polymer', 'crystal',
        'solvent', 'solute', 'solution', 'precipitation', 'titration'
      ],
      'sv': [
        'atom', 'molekyl', 'grundämne', 'förening', 'reaktion', 'bindning',
        'jonisk', 'kovalent', 'elektron', 'proton', 'neutron',
        'periodiska systemet', 'oxidation', 'reduktion', 'syra', 'bas',
        'ph', 'katalysator', 'jämvikt', 'entalpi', 'entropi',
        'molaritet', 'molalitet', 'stökiometri', 'termodynamik',
        'kinetik', 'organisk', 'oorganisk', 'polymer', 'kristall',
        'lösningsmedel', 'löst ämne', 'lösning', 'utfällning', 'titrering',
        'kemi', 'kemisk', 'ämne', 'grundämne'
      ]
    },
    'Physics': {
      'en': [
        'force', 'energy', 'momentum', 'velocity', 'acceleration',
        'gravity', 'friction', 'wave', 'frequency', 'amplitude',
        'electromagnetic', 'quantum', 'relativity', 'thermodynamics',
        'mechanics', 'optics', 'electricity', 'magnetism', 'nuclear',
        'particle', 'photon', 'electron', 'neutron', 'proton',
        'mass', 'weight', 'density', 'pressure', 'temperature',
        'heat', 'work', 'power', 'electric field', 'magnetic field'
      ],
      'sv': [
        'kraft', 'energi', 'rörelsemängd', 'hastighet', 'acceleration',
        'tyngdkraft', 'friktion', 'våg', 'frekvens', 'amplitud',
        'elektromagnetisk', 'kvant', 'relativitet', 'termodynamik',
        'mekanik', 'optik', 'elektricitet', 'magnetism', 'kärnfysik',
        'partikel', 'foton', 'elektron', 'neutron', 'proton',
        'massa', 'vikt', 'densitet', 'tryck', 'temperatur',
        'värme', 'arbete', 'effekt', 'elektriskt fält', 'magnetfält',
        'fysik', 'fysikalisk', 'rörelse', 'materia'
      ]
    },
    'History': {
      'en': [
        'ancient', 'medieval', 'renaissance', 'revolution', 'empire',
        'dynasty', 'civilization', 'culture', 'tradition', 'artifact',
        'archaeology', 'chronology', 'timeline', 'century', 'decade',
        'war', 'peace', 'treaty', 'alliance', 'conquest',
        'government', 'democracy', 'monarchy', 'republic', 'constitution',
        'social', 'economic', 'political', 'religious', 'cultural'
      ],
      'sv': [
        'antik', 'medeltid', 'renässans', 'revolution', 'imperium',
        'dynasti', 'civilisation', 'kultur', 'tradition', 'artefakt',
        'arkeologi', 'kronologi', 'tidslinje', 'århundrade', 'årtionde',
        'krig', 'fred', 'fördrag', 'allians', 'erövring',
        'regering', 'demokrati', 'monarki', 'republik', 'konstitution',
        'social', 'ekonomisk', 'politisk', 'religiös', 'kulturell',
        'historia', 'historisk', 'forntid', 'nutid', 'dåtid'
      ]
    },
    'Geography': {
      'en': [
        'continent', 'country', 'city', 'ocean', 'sea', 'river',
        'mountain', 'valley', 'desert', 'forest', 'climate',
        'weather', 'temperature', 'precipitation', 'ecosystem',
        'population', 'urban', 'rural', 'migration', 'settlement',
        'longitude', 'latitude', 'equator', 'hemisphere', 'tropics',
        'cartography', 'topography', 'geology', 'hydrology', 'demographics'
      ],
      'sv': [
        'kontinent', 'land', 'stad', 'hav', 'sjö', 'flod',
        'berg', 'dal', 'öken', 'skog', 'klimat',
        'väder', 'temperatur', 'nederbörd', 'ekosystem',
        'befolkning', 'urban', 'rural', 'migration', 'bosättning',
        'longitud', 'latitud', 'ekvator', 'hemisfär', 'tropiker',
        'kartografi', 'topografi', 'geologi', 'hydrologi', 'demografi',
        'geografi', 'geografisk', 'plats', 'område', 'region'
      ]
    }
  };

  /// Direct text classification method (for testing or manual text input)
  static Future<ClassificationResult> classifyText(String text) async {
    if (text.isEmpty) {
      return ClassificationResult(
        subject: 'Unknown',
        confidence: 0.0,
        detectedLanguage: 'en',
        extractedText: '',
        tags: [],
      );
    }

    // Detect language
    final String detectedLanguage = await _detectLanguage(text);
    
    // Classify subject based on text content
    return await _classifyTextContent(text, detectedLanguage);
  }

  /// Main classification method that processes an image and returns subject + tags
  static Future<ClassificationResult> classifyImage(File imageFile) async {
    try {
      // Step 1: Extract text using Google ML Kit OCR
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        return ClassificationResult(
          subject: 'General',
          tags: ['no text detected'],
          confidence: 0.0,
          detectedLanguage: 'unknown',
          extractedText: '',
        );
      }

      // Step 2: Detect language
      final String detectedLanguage = await _detectLanguage(recognizedText.text);
      
      // Step 3: Classify subject based on text content
      final ClassificationResult result = await _classifyTextContent(
        recognizedText.text,
        detectedLanguage,
      );

      return result.copyWith(
        extractedText: recognizedText.text,
        detectedLanguage: detectedLanguage,
      );

    } catch (e) {
      print('AI Classification Error: $e');
      return ClassificationResult(
        subject: 'General',
        tags: ['classification error'],
        confidence: 0.0,
        detectedLanguage: 'unknown',
        extractedText: '',
      );
    }
  }

  /// Detect language of the extracted text
  static Future<String> _detectLanguage(String text) async {
    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(text);
      if (languageCode != 'und') { // 'und' means undetermined
        return languageCode;
      }
    } catch (e) {
      // ML Kit failed, use simple keyword-based detection
    }
    
    // Fallback: Simple Swedish keyword detection
    final swedishWords = [
      'fotosyntes', 'koldioxid', 'vatten', 'syre', 'glukos',
      'matematik', 'matte', 'ekvation', 'formel', 'räkna',
      'kemi', 'molekyl', 'atom', 'ämne', 'reaktion',
      'fysik', 'kraft', 'energi', 'hastighet', 'tryck',
      'cell', 'dna', 'organism', 'evolution', 'gen',
      'och', 'eller', 'med', 'från', 'till', 'av', 'på'
    ];
    
    final String lowerText = text.toLowerCase();
    for (final swedishWord in swedishWords) {
      if (lowerText.contains(swedishWord)) {
        return 'sv';
      }
    }
    
    return 'en'; // Default to English
  }

  /// Classify text content into educational subjects
  static Future<ClassificationResult> _classifyTextContent(String text, String language) async {
    final String normalizedText = text.toLowerCase();
    final Map<String, double> subjectScores = {};
    final Map<String, List<String>> subjectTags = {};

    // Score each subject based on keyword matches
    for (final MapEntry<String, Map<String, List<String>>> subjectEntry in _educationalKeywords.entries) {
      final String subject = subjectEntry.key;
      final Map<String, List<String>> languageKeywords = subjectEntry.value;
      
      double score = 0.0;
      final List<String> matchedTags = [];

      // Check keywords for detected language first, then fallback to English
      final List<String> keywordsToCheck = [
        ...languageKeywords[language] ?? [],
        ...languageKeywords['en'] ?? [],
      ];

      for (final String keyword in keywordsToCheck) {
        if (normalizedText.contains(keyword.toLowerCase())) {
          score += _calculateKeywordWeight(keyword, subject);
          if (!matchedTags.contains(keyword)) {
            matchedTags.add(keyword);
          }
        }
      }

      if (score > 0) {
        subjectScores[subject] = score;
        subjectTags[subject] = matchedTags;
      }
    }

    // Find the subject with the highest score
    if (subjectScores.isEmpty) {
      return ClassificationResult(
        subject: 'General',
        tags: ['unclassified content'],
        confidence: 0.0,
        detectedLanguage: language,
        extractedText: text,
      );
    }

    final MapEntry<String, double> topSubject = subjectScores.entries
        .reduce((a, b) => a.value > b.value ? a : b);

    return ClassificationResult(
      subject: topSubject.key,
      tags: subjectTags[topSubject.key] ?? [],
      confidence: topSubject.value / 10.0, // Normalize confidence
      detectedLanguage: language,
      extractedText: text,
    );
  }

  /// Calculate weight for keyword matches based on importance
  static double _calculateKeywordWeight(String keyword, String subject) {
    // Core subject keywords get higher weight
    final Map<String, List<String>> coreKeywords = {
      'Mathematics': ['equation', 'algebra', 'calculus', 'ekvation', 'matte'],
      'Biology': ['cell', 'dna', 'mitochondria', 'cell', 'biologi'],
      'Chemistry': ['atom', 'molecule', 'reaction', 'kemi', 'kemisk'],
      'Physics': ['force', 'energy', 'wave', 'fysik', 'kraft'],
      'History': ['ancient', 'revolution', 'historia', 'historisk'],
      'Geography': ['continent', 'climate', 'geografi', 'geografisk'],
    };

    if (coreKeywords[subject]?.contains(keyword.toLowerCase()) == true) {
      return 3.0; // High weight for core keywords
    }
    return 1.0; // Normal weight for other keywords
  }

  /// Search images by content - supports both English and Swedish queries
  static Future<List<String>> searchImagesByContent(
    String query,
    List<String> imagePaths,
  ) async {
    final List<String> matchingImages = [];
    final String normalizedQuery = query.toLowerCase();

    for (final String imagePath in imagePaths) {
      try {
        final File imageFile = File(imagePath);
        if (!await imageFile.exists()) continue;

        final ClassificationResult result = await classifyImage(imageFile);
        
        // Check if query matches extracted text, tags, or subject
        final bool matches = 
            result.extractedText.toLowerCase().contains(normalizedQuery) ||
            result.tags.any((tag) => tag.toLowerCase().contains(normalizedQuery)) ||
            result.subject.toLowerCase().contains(normalizedQuery);

        if (matches) {
          matchingImages.add(imagePath);
        }
      } catch (e) {
        print('Error searching image $imagePath: $e');
      }
    }

    return matchingImages;
  }

  /// Dispose resources
  static void dispose() {
    _textRecognizer.close();
    _languageIdentifier.close();
  }
}

/// Result of AI classification
class ClassificationResult {
  final String subject;
  final List<String> tags;
  final double confidence;
  final String detectedLanguage;
  final String extractedText;

  const ClassificationResult({
    required this.subject,
    required this.tags,
    required this.confidence,
    required this.detectedLanguage,
    required this.extractedText,
  });

  ClassificationResult copyWith({
    String? subject,
    List<String>? tags,
    double? confidence,
    String? detectedLanguage,
    String? extractedText,
  }) {
    return ClassificationResult(
      subject: subject ?? this.subject,
      tags: tags ?? this.tags,
      confidence: confidence ?? this.confidence,
      detectedLanguage: detectedLanguage ?? this.detectedLanguage,
      extractedText: extractedText ?? this.extractedText,
    );
  }

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'tags': tags,
    'confidence': confidence,
    'detectedLanguage': detectedLanguage,
    'extractedText': extractedText,
  };

  factory ClassificationResult.fromJson(Map<String, dynamic> json) => 
      ClassificationResult(
        subject: json['subject'] ?? 'General',
        tags: List<String>.from(json['tags'] ?? []),
        confidence: (json['confidence'] ?? 0.0).toDouble(),
        detectedLanguage: json['detectedLanguage'] ?? 'unknown',
        extractedText: json['extractedText'] ?? '',
      );

  @override
  String toString() {
    return 'ClassificationResult(subject: $subject, tags: $tags, confidence: ${confidence.toStringAsFixed(2)}, language: $detectedLanguage)';
  }
}