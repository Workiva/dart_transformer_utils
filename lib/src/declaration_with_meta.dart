library transformer_utils.src.declaration_with_meta;

import 'package:analyzer/analyzer.dart';
import 'package:barback/barback.dart';

class DeclarationWithMeta<DeclarationT extends Declaration, AnnotationT> {
  final AnnotationT annotation;
  final AssetId assetId;
  final DeclarationT node;

  DeclarationWithMeta(this.node, this.annotation, {this.assetId});
}
