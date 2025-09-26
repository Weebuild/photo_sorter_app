import 'package:flutter_test/flutter_test.dart';
import 'package:photo_sorter_app/services/real_ai_classifier.dart';
import 'dart:io';

void main() {
  group('RealAIClassifier Tests', () {
    test('should classify text with educational keywords', () async {
      // Test English math content
      final result = await RealAIClassifier.classifyText(
        'quadratic equation: ax² + bx + c = 0'
      );
      
      expect(result.subject, equals('Mathematics'));
      expect(result.detectedLanguage, equals('en'));
      expect(result.confidence, greaterThan(0.0));
    });

    test('should detect Swedish content', () async {
      // Test Swedish biology content - fotosyntes is the Swedish word
      final result = await RealAIClassifier.classifyText(
        'fotosyntes: koldioxid + vatten + ljus → glukos + syre'
      );
      
      expect(result.subject, equals('Biology'));
      expect(result.detectedLanguage, equals('sv'));
      expect(result.confidence, greaterThan(0.0));
    });

    test('should return general for non-educational content', () async {
      final result = await RealAIClassifier.classifyText(
        'This is just random text about nothing educational'
      );
      
      expect(result.subject, equals('General'));
      expect(result.confidence, lessThan(0.3));
    });

    test('should handle empty text', () async {
      final result = await RealAIClassifier.classifyText('');
      
      expect(result.subject, equals('Unknown'));
      expect(result.confidence, equals(0.0));
    });
  });
}