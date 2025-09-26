import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:google_mlkit_language_id/google_mlkit_language_id.dart';
import 'dart:io';

/// Real AI Classification Result with detailed analysis
class AIClassificationResult {
  final String subject;
  final double confidence;
  final String detectedLanguage;
  final String extractedText;
  final List<String> educationalKeywords;
  final Map<String, double> subjectScores;

  AIClassificationResult({
    required this.subject,
    required this.confidence,
    required this.detectedLanguage,
    required this.extractedText,
    required this.educationalKeywords,
    required this.subjectScores,
  });
}

/// Production-ready AI Classifier using Google ML Kit
class ProductionAIClassifier {
  static final TextRecognizer _textRecognizer = TextRecognizer();
  static final LanguageIdentifier _languageIdentifier = LanguageIdentifier(confidenceThreshold: 0.5);
  
  // Comprehensive educational keyword database
  static const Map<String, Map<String, List<String>>> _educationalDatabase = {
    'Mathematics': {
      'en': [
        'equation', 'formula', 'algebra', 'geometry', 'calculus', 'derivative',
        'integral', 'function', 'matrix', 'polynomial', 'theorem', 'proof',
        'variable', 'coefficient', 'logarithm', 'exponential', 'sine', 'cosine',
        'tangent', 'limit', 'infinity', 'sqrt', 'quadratic', 'linear', 'graph',
        'plot', 'axis', 'coordinate', 'mathematics', 'math', 'number', 'solve',
        '+', '-', '×', '÷', '=', '≠', '≤', '≥', '<', '>', 'π', '∞', '∑', '∫'
      ],
      'sv': [
        'ekvation', 'formel', 'algebra', 'geometri', 'matematik', 'derivata',
        'integral', 'funktion', 'matris', 'polynom', 'sats', 'bevis',
        'variabel', 'koefficient', 'logaritm', 'exponentiell', 'sinus', 'cosinus',
        'tangens', 'gräns', 'oändlighet', 'kvadratrot', 'kvadratisk', 'linjär',
        'graf', 'diagram', 'axel', 'koordinat', 'matte', 'tal', 'siffra', 'lösa'
      ]
    },
    'Biology': {
      'en': [
        'cell', 'dna', 'rna', 'protein', 'enzyme', 'mitochondria', 'chloroplast',
        'nucleus', 'membrane', 'chromosome', 'gene', 'evolution', 'species',
        'organism', 'bacteria', 'virus', 'photosynthesis', 'respiration',
        'metabolism', 'homeostasis', 'ecosystem', 'biodiversity', 'genetics',
        'heredity', 'mutation', 'natural selection', 'adaptation', 'reproduction',
        'meiosis', 'mitosis', 'tissue', 'organ', 'system', 'anatomy', 'physiology',
        'biology', 'life', 'living', 'carbon', 'oxygen', 'glucose', 'atp'
      ],
      'sv': [
        'cell', 'dna', 'rna', 'protein', 'enzym', 'mitokondrier', 'kloroplast',
        'kärna', 'membran', 'kromosom', 'gen', 'evolution', 'art', 'organism',
        'bakterie', 'virus', 'fotosyntes', 'andning', 'ämnesomsättning',
        'homeostas', 'ekosystem', 'biodiversitet', 'genetik', 'ärftlighet',
        'mutation', 'naturligt urval', 'anpassning', 'fortplantning', 'meios',
        'mitos', 'vävnad', 'organ', 'system', 'anatomi', 'fysiologi', 'biologi',
        'liv', 'levande', 'kol', 'syre', 'glukos', 'energi'
      ]
    },
    'Chemistry': {
      'en': [
        'atom', 'molecule', 'element', 'compound', 'reaction', 'chemical',
        'bond', 'ionic', 'covalent', 'periodic table', 'electron', 'proton',
        'neutron', 'valence', 'oxidation', 'reduction', 'acid', 'base', 'ph',
        'buffer', 'catalyst', 'equilibrium', 'stoichiometry', 'mole', 'molarity',
        'concentration', 'solution', 'solvent', 'solute', 'organic', 'inorganic',
        'chemistry', 'carbon', 'hydrogen', 'oxygen', 'nitrogen', 'halogen'
      ],
      'sv': [
        'atom', 'molekyl', 'grundämne', 'förening', 'reaktion', 'kemisk',
        'bindning', 'jonisk', 'kovalent', 'periodiska systemet', 'elektron',
        'proton', 'neutron', 'valens', 'oxidation', 'reduktion', 'syra', 'bas',
        'ph-värde', 'buffert', 'katalysator', 'jämvikt', 'stökiometri', 'mol',
        'molaritet', 'koncentration', 'lösning', 'lösningsmedel', 'löst ämne',
        'organisk', 'oorganisk', 'kemi', 'kol', 'väte', 'syre', 'kväve'
      ]
    },
    'Physics': {
      'en': [
        'force', 'energy', 'motion', 'velocity', 'acceleration', 'mass',
        'weight', 'gravity', 'friction', 'momentum', 'work', 'power',
        'pressure', 'temperature', 'heat', 'wave', 'frequency', 'wavelength',
        'electromagnetic', 'light', 'optics', 'electricity', 'current',
        'voltage', 'resistance', 'magnetism', 'quantum', 'relativity',
        'physics', 'newton', 'joule', 'watt', 'volt', 'ampere', 'ohm'
      ],
      'sv': [
        'kraft', 'energi', 'rörelse', 'hastighet', 'acceleration', 'massa',
        'vikt', 'gravitation', 'friktion', 'rörelsemängd', 'arbete', 'effekt',
        'tryck', 'temperatur', 'värme', 'våg', 'frekvens', 'våglängd',
        'elektromagnetisk', 'ljus', 'optik', 'elektricitet', 'ström',
        'spänning', 'motstånd', 'magnetism', 'kvant', 'relativitet',
        'fysik', 'newton', 'joule', 'watt', 'volt', 'ampere', 'ohm'
      ]
    },
    'History': {
      'en': [
        'history', 'historical', 'century', 'year', 'war', 'battle', 'empire',
        'revolution', 'king', 'queen', 'president', 'government', 'democracy',
        'monarchy', 'republic', 'ancient', 'medieval', 'renaissance', 'modern',
        'timeline', 'chronology', 'civilization', 'culture', 'society',
        'political', 'economic', 'social', 'date', 'period', 'era', 'age'
      ],
      'sv': [
        'historia', 'historisk', 'århundrade', 'år', 'krig', 'slag', 'imperium',
        'revolution', 'kung', 'drottning', 'president', 'regering', 'demokrati',
        'monarki', 'republik', 'antik', 'medeltida', 'renässans', 'modern',
        'tidslinje', 'kronologi', 'civilisation', 'kultur', 'samhälle',
        'politisk', 'ekonomisk', 'social', 'datum', 'period', 'epok', 'tidevarv'
      ]
    },
    'Geography': {
      'en': [
        'geography', 'continent', 'country', 'city', 'ocean', 'sea', 'river',
        'mountain', 'valley', 'desert', 'forest', 'climate', 'weather',
        'temperature', 'precipitation', 'ecosystem', 'population', 'urban',
        'rural', 'migration', 'settlement', 'longitude', 'latitude', 'equator',
        'hemisphere', 'tropics', 'map', 'atlas', 'compass', 'scale', 'legend'
      ],
      'sv': [
        'geografi', 'kontinent', 'land', 'stad', 'hav', 'sjö', 'flod',
        'berg', 'dal', 'öken', 'skog', 'klimat', 'väder', 'temperatur',
        'nederbörd', 'ekosystem', 'befolkning', 'urban', 'landsbygd',
        'migration', 'bosättning', 'longitud', 'latitud', 'ekvator',
        'hemisfär', 'tropikerna', 'karta', 'atlas', 'kompass', 'skala'
      ]
    }
  };

  /// Main AI classification method
  static Future<AIClassificationResult> classifyImage(File imageFile) async {
    try {
      // Step 1: Extract text using ML Kit OCR
      final InputImage inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isEmpty) {
        return AIClassificationResult(
          subject: 'General',
          confidence: 0.0,
          detectedLanguage: 'unknown',
          extractedText: '',
          educationalKeywords: [],
          subjectScores: {},
        );
      }

      // Step 2: Detect language
      final String detectedLanguage = await _detectLanguage(recognizedText.text);
      
      // Step 3: Analyze text for educational content
      final analysisResult = _analyzeEducationalContent(recognizedText.text, detectedLanguage);

      return AIClassificationResult(
        subject: analysisResult['subject'],
        confidence: analysisResult['confidence'],
        detectedLanguage: detectedLanguage,
        extractedText: recognizedText.text,
        educationalKeywords: analysisResult['keywords'],
        subjectScores: analysisResult['scores'],
      );

    } catch (e) {
      print('AI Classification Error: $e');
      return AIClassificationResult(
        subject: 'General',
        confidence: 0.0,
        detectedLanguage: 'unknown',
        extractedText: '',
        educationalKeywords: [],
        subjectScores: {},
      );
    }
  }

  /// Detect language with fallback
  static Future<String> _detectLanguage(String text) async {
    try {
      final String languageCode = await _languageIdentifier.identifyLanguage(text);
      if (languageCode != 'und') {
        return languageCode;
      }
    } catch (e) {
      print('Language detection error: $e');
    }
    
    // Fallback: Check for Swedish keywords
    final swedishIndicators = ['och', 'eller', 'med', 'från', 'till', 'av', 'på', 'för', 'är', 'det'];
    final lowerText = text.toLowerCase();
    
    for (final indicator in swedishIndicators) {
      if (lowerText.contains(' $indicator ') || lowerText.startsWith('$indicator ') || lowerText.endsWith(' $indicator')) {
        return 'sv';
      }
    }
    
    return 'en'; // Default to English
  }

  /// Analyze educational content with advanced scoring
  static Map<String, dynamic> _analyzeEducationalContent(String text, String language) {
    final String normalizedText = text.toLowerCase();
    final Map<String, double> subjectScores = {};
    final List<String> foundKeywords = [];
    
    // Calculate scores for each subject
    for (final entry in _educationalDatabase.entries) {
      final String subject = entry.key;
      final Map<String, List<String>> languageKeywords = entry.value;
      
      double score = 0.0;
      final List<String> subjectKeywords = [];
      
      // Check keywords for detected language first
      if (languageKeywords.containsKey(language)) {
        for (final keyword in languageKeywords[language]!) {
          if (normalizedText.contains(keyword.toLowerCase())) {
            score += _calculateKeywordWeight(keyword, normalizedText);
            subjectKeywords.add(keyword);
            if (!foundKeywords.contains(keyword)) {
              foundKeywords.add(keyword);
            }
          }
        }
      }
      
      // Also check English keywords as fallback
      if (language != 'en' && languageKeywords.containsKey('en')) {
        for (final keyword in languageKeywords['en']!) {
          if (normalizedText.contains(keyword.toLowerCase())) {
            score += _calculateKeywordWeight(keyword, normalizedText) * 0.7; // Slightly lower weight
            subjectKeywords.add(keyword);
            if (!foundKeywords.contains(keyword)) {
              foundKeywords.add(keyword);
            }
          }
        }
      }
      
      if (score > 0) {
        subjectScores[subject] = score;
      }
    }

    // Determine best subject and confidence
    if (subjectScores.isEmpty) {
      return {
        'subject': 'General',
        'confidence': 0.0,
        'keywords': foundKeywords,
        'scores': subjectScores,
      };
    }

    final bestSubject = subjectScores.entries.reduce((a, b) => a.value > b.value ? a : b);
    final maxScore = bestSubject.value;
    final totalScore = subjectScores.values.reduce((a, b) => a + b);
    
    // Calculate confidence based on score dominance
    final confidence = (maxScore / (totalScore + 1)).clamp(0.0, 1.0);
    
    // Only classify if confidence is above threshold
    final String finalSubject = confidence >= 0.3 ? bestSubject.key : 'General';

    return {
      'subject': finalSubject,
      'confidence': confidence,
      'keywords': foundKeywords,
      'scores': subjectScores,
    };
  }

  /// Calculate keyword weight based on context and frequency
  static double _calculateKeywordWeight(String keyword, String text) {
    final occurrences = keyword.allMatches(text.toLowerCase()).length;
    double weight = 1.0;
    
    // Mathematical symbols and formulas get higher weight
    if (keyword.contains(RegExp(r'[+\-×÷=≠≤≥<>π∞∑∫]'))) {
      weight = 2.0;
    }
    // Scientific terms get higher weight
    else if (['dna', 'rna', 'photosynthesis', 'mitochondria', 'equation', 'molecule'].contains(keyword.toLowerCase())) {
      weight = 1.5;
    }
    // Common words get lower weight
    else if (keyword.length <= 3) {
      weight = 0.5;
    }
    
    return weight * occurrences;
  }

  /// Dispose of resources
  static void dispose() {
    _textRecognizer.close();
    _languageIdentifier.close();
  }
}