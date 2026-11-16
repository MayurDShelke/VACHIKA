import 'package:flutter_test/flutter_test.dart';
import 'package:vachika/core/utils/isl_glosser.dart';
import 'package:vachika/data/repositories/sign_dictionary_repository.dart';

void main() {
  group('IslGlosser Tests', () {
    test('removes stop words (am, to, the)', () {
      final result = IslGlosser.gloss('I am going to school');
      final glosses = result.activeTokens.map((t) => t.glossForm).toList();

      expect(glosses.contains('AM'), isFalse);
      expect(glosses.contains('TO'), isFalse);
    });

    test('maps pronouns to ISL gloss forms', () {
      final result = IslGlosser.gloss('I and you');
      final glosses = result.activeTokens.map((t) => t.glossForm).toList();

      expect(glosses.contains('ME'), isTrue);
      expect(glosses.contains('YOU'), isTrue);
    });

    test('reorders to Subject-Object-Verb (SOV) order', () {
      final result = IslGlosser.gloss('I want food');
      final glosses = result.activeTokens.map((t) => t.glossForm).toList();

      // Subject (ME) -> Object (FOOD) -> Verb (WANT)
      expect(glosses, equals(['ME', 'FOOD', 'WANT']));
    });

    test('maps greeting words like hello and thank you', () {
      final result = IslGlosser.gloss('hello thank you');
      final glosses = result.activeTokens.map((t) => t.glossForm).toList();

      expect(glosses.contains('HELLO'), isTrue);
      expect(glosses.contains('THANK-YOU'), isTrue);
    });
  });

  group('SignDictionaryRepository Tests', () {
    test('resolves dictionary signs', () {
      final tokens = [
        const GlossToken(
          originalWord: 'school',
          glossForm: 'SCHOOL',
          type: GlossTokenType.noun,
        ),
      ];

      final items = SignDictionaryRepository.instance.resolve(tokens);
      expect(items.length, 1);
      expect(items.first.isFingerspelled, isFalse);
      expect(items.first.sign.gloss, 'SCHOOL');
    });

    test('falls back to fingerspelling for unknown words', () {
      final tokens = [
        const GlossToken(
          originalWord: 'pizza',
          glossForm: 'PIZZA',
          type: GlossTokenType.noun,
        ),
      ];

      final items = SignDictionaryRepository.instance.resolve(tokens);
      // P - I - Z - Z - A => 5 letters
      expect(items.length, 5);
      expect(items.every((it) => it.isFingerspelled), isTrue);
      expect(items.map((it) => it.sign.gloss).join(), 'PIZZA');
    });
  });
}
