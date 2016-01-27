@TestOn('vm')
library transformer_utils.test.unit.analyzer_helpers_test;

import 'package:test/test.dart';

import 'package:transformer_utils/transformer_utils.dart';

import '../test_utils.dart';

main() {
  group('instantiateAnnotation()', () {
    group('instantiates an annotation with a parameter value specified as', () {
      test('a string literal', () {
        var node = parseAndGetSingleMember('@TestAnnotation("hello")\nvar a;');
        TestAnnotation instance = instantiateAnnotation(node, TestAnnotation);
        expect(instance.positional, "hello");
      });

      test('a concatenated string literal', () {
        var node = parseAndGetSingleMember('@TestAnnotation("he" "y")\nvar a;');
        TestAnnotation instance = instantiateAnnotation(node, TestAnnotation);
        expect(instance.positional, "hey");
      });

      test('a boolean literal', () {
        var node = parseAndGetSingleMember('@TestAnnotation(true)\nvar a;');
        TestAnnotation instance = instantiateAnnotation(node, TestAnnotation);
        expect(instance.positional, true);
      });

      test('an integer literal', () {
        var node = parseAndGetSingleMember('@TestAnnotation(1)\nvar a;');
        TestAnnotation instance = instantiateAnnotation(node, TestAnnotation);
        expect(instance.positional, 1);
      });

      test('a null literal', () {
        var node = parseAndGetSingleMember('@TestAnnotation(null)\nvar a;');
        TestAnnotation instance = instantiateAnnotation(node, TestAnnotation);
        expect(instance.positional, null);
      });
    });

    group('throws when an annotation parameter value is unsupported:', () {
      test('a constant expression', () {
        var node = parseAndGetSingleMember('@TestAnnotation(const [])\nvar a;');
        expect(() => instantiateAnnotation(node, TestAnnotation), throws);
      });

      test('an interpolated String', () {
        var node = parseAndGetSingleMember('@TestAnnotation("\$v")\nvar a;');
        expect(() => instantiateAnnotation(node, TestAnnotation), throws);
      });

      test('an identifier', () {
        var node =
            parseAndGetSingleMember('@TestAnnotation(identifier)\nvar a;');
        expect(() => instantiateAnnotation(node, TestAnnotation), throws);
      });
    });

    test('annotation with both named and positional parameters', () {
      var node =
          parseAndGetSingleMember('@TestAnnotation(1, named: 2)\nvar a;');
      TestAnnotation instance = instantiateAnnotation(node, TestAnnotation);
      expect(instance.positional, 1);
      expect(instance.named, 2);
    });

    test('instantiates an annotation using a named constructor', () {
      var node = parseAndGetSingleMember(
          '@TestAnnotation.namedConstructor(namedConstructorOnly: true)\nvar a;');
      TestAnnotation instance = instantiateAnnotation(node, TestAnnotation);
      expect(instance.namedConstructorOnly, true);
    });

    test('throws if the annotation cannot be constructed', () {
      var node = parseAndGetSingleMember(
          '@TestAnnotation(1, 2, 3, 4, "way more parameters than were declared")\nvar a;');
      expect(() {
        instantiateAnnotation(node, TestAnnotation);
      }, throwsA(startsWith('Unable to instantiate annotation')));
    });

    test('throws if the annotation is not used as a constructor', () {
      var node = parseAndGetSingleMember('@TestAnnotation\nvar a;');
      expect(() {
        instantiateAnnotation(node, TestAnnotation);
      }, throwsA(startsWith('Annotation not invocation of constructor')));
    });

    test('returns null when the member is not annotated', () {
      var node = parseAndGetSingleMember('var a;');
      expect(instantiateAnnotation(node, TestAnnotation), isNull);
    });

    test('returns null when the member has only non-matching annotations', () {
      var node = parseAndGetSingleMember('@NonexistantAnnotation\nvar a;');
      expect(instantiateAnnotation(node, TestAnnotation), isNull);
    });
  });
}
