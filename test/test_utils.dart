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

ConstructorDeclaration getConstructor(ClassDeclaration classDecl,
    {String name}) {
  for (var member in classDecl.members) {
    if (member is ConstructorDeclaration && member.name?.name == name) {
      return member;
    }
  }
  return null;
}

FieldDeclaration getFieldByName(ClassDeclaration classDecl, String name) {
  for (var member in classDecl.members) {
    if (member is FieldDeclaration &&
        member.fields.variables.first.name.name == name) {
      return member;
    }
  }
  return null;
}

MethodDeclaration getMethodByName(ClassDeclaration classDecl, String name) {
  for (var member in classDecl.members) {
    if (member is MethodDeclaration && member.name.name == name) {
      return member;
    }
  }
  return null;
}

CompilationUnitMember parseAndGetSingleMember(String source) {
  var compilationUnit = parseCompilationUnit(source);
  return compilationUnit.declarations.single;
}
