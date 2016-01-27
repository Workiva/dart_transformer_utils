library transformer_utils.src.barback_utils;

import 'package:analyzer/analyzer.dart';
import 'package:barback/barback.dart';
import 'package:path/path.dart' as path;
import 'package:source_span/source_span.dart';

/// Converts [id] to a "package:" URI.
///
/// This will return a schemeless URI if [id] doesn't represent a library in
/// `lib/`.
Uri assetIdToPackageUri(AssetId id) {
  if (!id.path.startsWith('lib/')) return new Uri(path: id.path);
  return new Uri(
      scheme: 'package',
      path: path.url.join(id.package, id.path.replaceFirst('lib/', '')));
}

/// Returns a [SourceSpan] spanning from the beginning to the end of the given
/// [node]. The preceding comment and metadata will be excluded if
/// [skipCommentAndMetadata] is true.
SourceSpan getSpanForNode(SourceFile sourceFile, AstNode node,
    {bool skipCommentAndMetadata: true}) {
  if (skipCommentAndMetadata && node is AnnotatedNode) {
    return sourceFile.span(
        node.firstTokenAfterCommentAndMetadata.offset, node.end);
  }

  return sourceFile.span(node.offset, node.end);
}
