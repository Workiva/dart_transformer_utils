@TestOn('vm')
library transformer_utils.test.unit.node_with_meta_test;

import 'package:analyzer/analyzer.dart';
import 'package:test/test.dart';

import 'package:transformer_utils/transformer_utils.dart';

import '../test_utils.dart';

void main() {
  group('NodeWithMeta', () {
    test('instantiates and provides access to an annotation for a given node',
        () {
      var member = parseAndGetSingleMember('@TestAnnotation("hello")\nvar a;');
      var nodeWithMeta =
          new NodeWithMeta<TopLevelVariableDeclaration, TestAnnotation>(member);

      expect(nodeWithMeta.node, same(member));
      expect(nodeWithMeta.meta, isNotNull);
      expect(nodeWithMeta.meta.positional, 'hello');
    });
  });
}
