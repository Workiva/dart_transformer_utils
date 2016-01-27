@TestOn('vm')
library transformer_utils.test.unit.barback_utils_test;

import 'package:analyzer/analyzer.dart';
import 'package:barback/barback.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';

import 'package:transformer_utils/src/barback_utils.dart';

const String sourceFileText = '''
var plainVar = "plain";

/// Comment
@Annotation()
var varWithCommentAndMeta = "annotated";
''';

void main() {
  group('assetIdToPackageUri()', () {
    test('returns original path for non-lib file', () {
      var assetId = new AssetId('transformer_utils', 'test/test_utils.dart');
      expect(assetIdToPackageUri(assetId), Uri.parse('test/test_utils.dart'));
    });

    test('returns path with "package" scheme for lib file', () {
      var assetId =
          new AssetId('transformer_utils', 'lib/transformer_utils.dart');
      expect(assetIdToPackageUri(assetId),
          Uri.parse('package:transformer_utils/transformer_utils.dart'));
    });
  });

  group('getSpanForNode()', () {
    test('should get node but skip comment and meta by default', () {
      var sourceFile = new SourceFile(sourceFileText);
      var unit = parseCompilationUnit(sourceFileText);
      var annotatedNode = unit.childEntities.last as AstNode;
      var span = getSpanForNode(sourceFile, annotatedNode);
      expect(span.text, 'var varWithCommentAndMeta = "annotated";');
    });

    test('should not skip comment and meta if skip is false', () {
      var sourceFile = new SourceFile(sourceFileText);
      var unit = parseCompilationUnit(sourceFileText);
      var annotatedNode = unit.childEntities.last as AstNode;
      var span = getSpanForNode(sourceFile, annotatedNode,
          skipCommentAndMetadata: false);
      expect(
          span.text,
          [
            '/// Comment',
            '@Annotation()',
            'var varWithCommentAndMeta = "annotated";'
          ].join('\n'));
    });

    test('should return the whole span if the node is not annotated', () {
      var sourceFile = new SourceFile(sourceFileText);
      var unit = parseCompilationUnit(sourceFileText);
      var plainNode = unit.childEntities.first as AstNode;
      var span = getSpanForNode(sourceFile, plainNode);
      expect(span.text, 'var plainVar = "plain";');
    });
  });
}
