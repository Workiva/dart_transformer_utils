library transformer_utils.src.node_with_meta;

import 'package:analyzer/analyzer.dart';

import 'package:transformer_utils/src/analyzer_helpers.dart';

/// Utility class that allows for easy access to an annotated node's
/// instantiated annotation.
class NodeWithMeta<TNode extends AnnotatedNode, TMeta> {
  final TNode node;
  final TMeta meta;

  /// Construct a [NodeWithMeta] instance from an [AnnotatedNode].
  /// The original node will be available via [node].
  /// The instantiated annotation of type `TMeta` will be available via [meta].
  NodeWithMeta(TNode unit)
      : this.node = unit,
        this.meta = instantiateAnnotation(unit, TMeta);
}
