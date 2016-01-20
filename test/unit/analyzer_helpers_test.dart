@TestOn('vm')
library transformer_utils.test.unit.analyzer_helpers_test;

import 'package:test/test.dart';

import 'package:transformer_utils/transformer_utils.dart';

import '../test_utils.dart';

main() {
  group('Analyzer Helpers', () {
    group('instantiateAnnotation()', () {
      group('instantiates an annotation with a parameter value specified as',
          () {
        test('a string literal', () {
          TestAnnotation instance = instantiateAnnotation(
              parseAndGetSingleMember('@TestAnnotation("hello")\nvar a;'),
              TestAnnotation);
          expect(instance.positional, "hello");
        });

        test('a concatenated string literal', () {
          TestAnnotation instance = instantiateAnnotation(
              parseAndGetSingleMember(
                  '@TestAnnotation("hello " "there")\nvar a;'),
              TestAnnotation);
          expect(instance.positional, "hello there");
        });

        test('a boolean literal', () {
          TestAnnotation instance = instantiateAnnotation(
              parseAndGetSingleMember('@TestAnnotation(true)\nvar a;'),
              TestAnnotation);
          expect(instance.positional, true);
        });

        test('an integer literal', () {
          TestAnnotation instance = instantiateAnnotation(
              parseAndGetSingleMember('@TestAnnotation(1)\nvar a;'),
              TestAnnotation);
          expect(instance.positional, 1);
        });

        test('a null literal', () {
          TestAnnotation instance = instantiateAnnotation(
              parseAndGetSingleMember('@TestAnnotation(null)\nvar a;'),
              TestAnnotation);
          expect(instance.positional, null);
        });
      });

      group(
          'throws when an annotation parameter value is specified as an unsupported value:',
          () {
        test('a constant expression', () {
          expect(
              () => instantiateAnnotation(
                  parseAndGetSingleMember('@TestAnnotation(const [])\nvar a;'),
                  TestAnnotation),
              throws);
        });

        test('an interpolated String', () {
          expect(
              () => instantiateAnnotation(
                  parseAndGetSingleMember(
                      '@TestAnnotation("\$someVariable")\nvar a;'),
                  TestAnnotation),
              throws);
        });

        test('a constant variable', () {
          expect(
              () => instantiateAnnotation(
                  parseAndGetSingleMember(
                      'const int one = 1;\n@TestAnnotation(one)\nvar a;'),
                  TestAnnotation),
              throws);
        });
      });

      test(
          'instantiates an annotation with both named and positional parameters',
          () {
        TestAnnotation instance = instantiateAnnotation(
            parseAndGetSingleMember('@TestAnnotation(1, named: 2)\nvar a;'),
            TestAnnotation);
        expect(instance.positional, 1);
        expect(instance.named, 2);
      });

      test('instantiates an annotation using a named constructor', () {
        TestAnnotation instance = instantiateAnnotation(
            parseAndGetSingleMember(
                '@TestAnnotation.namedConstructor(namedConstructorOnly: true)\nvar a;'),
            TestAnnotation);
        expect(instance.namedConstructorOnly, true);
      });

      test('throws if the annotation cannot be constructed', () {
        expect(
            () => instantiateAnnotation(
                parseAndGetSingleMember(
                    '@TestAnnotation(1, 2, 3, 4, "way more parameters than were declared")\nvar a;'),
                TestAnnotation),
            throwsA(startsWith('Unable to instantiate annotation')));
      });

      test('throws if the annotation is not used as a constructor', () {
        expect(
            () => instantiateAnnotation(
                parseAndGetSingleMember('@TestAnnotation\nvar a;'),
                TestAnnotation),
            throwsA(startsWith('Annotation not invocation of constructor')));
      });

      test('returns null when the member is not annotated', () {
        expect(
            instantiateAnnotation(
                parseAndGetSingleMember('var a;'), TestAnnotation),
            isNull);
      });

      test('returns null when the member has only non-matching annotations',
          () {
        expect(
            instantiateAnnotation(
                parseAndGetSingleMember('@NonexistantAnnotation\nvar a;'),
                TestAnnotation),
            isNull);
      });
    });
  });
}
