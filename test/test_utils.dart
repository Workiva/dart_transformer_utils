library transformer_utils.test_utils;

import 'package:analyzer/analyzer.dart';

class TestAnnotation {
  final positional;
  final named;
  final namedConstructorOnly;
  const TestAnnotation(this.positional, {this.named})
      : namedConstructorOnly = null;
  const TestAnnotation.namedConstructor({this.namedConstructorOnly})
      : positional = null,
        named = null;
}

CompilationUnitMember parseAndGetSingleMember(String source) {
  var compilationUnit = parseCompilationUnit(source);
  return compilationUnit.declarations.single;
}
