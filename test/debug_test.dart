import 'package:flutter_test/flutter_test.dart';
import 'package:photo_sorter_app/services/real_ai_classifier.dart';

void main() {
  test('debug classification', () async {
    final result1 = await RealAIClassifier.classifyText('quadratic equation: ax² + bx + c = 0');
    print('Math test: ${result1.subject}, confidence: ${result1.confidence}, lang: ${result1.detectedLanguage}');
    
    final result2 = await RealAIClassifier.classifyText('fotosyntes: koldioxid + vatten + ljus → glukos + syre');
    print('Swedish bio test: ${result2.subject}, confidence: ${result2.confidence}, lang: ${result2.detectedLanguage}');
    
    final result3 = await RealAIClassifier.classifyText('cell dna biology organism');
    print('English bio test: ${result3.subject}, confidence: ${result3.confidence}, lang: ${result3.detectedLanguage}');
    
    final result4 = await RealAIClassifier.classifyText('This is just random text');
    print('Random test: ${result4.subject}, confidence: ${result4.confidence}, lang: ${result4.detectedLanguage}');
  });
}