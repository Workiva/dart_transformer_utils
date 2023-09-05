// Copyright 2015 Workiva Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

library transformer_utils.test_utils;

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';

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

ConstructorDeclaration? getConstructor(ClassDeclaration classDecl,
    {String? name}) {
  for (var member in classDecl.members) {
    if (member is ConstructorDeclaration && member.name?.lexeme == name) {
      return member;
    }
  }
  return null;
}

FieldDeclaration? getFieldByName(ClassDeclaration classDecl, String name) {
  for (var member in classDecl.members) {
    if (member is FieldDeclaration &&
        member.fields.variables.first.name.lexeme == name) {
      return member;
    }
  }
  return null;
}

MethodDeclaration? getMethodByName(ClassDeclaration classDecl, String name) {
  for (var member in classDecl.members) {
    if (member is MethodDeclaration && member.name.lexeme == name) {
      return member;
    }
  }
  return null;
}

T parseAndGetSingleMember<T extends CompilationUnitMember>(String source) {
  var compilationUnit =
      parseString(content: source, throwIfDiagnostics: false).unit;
  return compilationUnit.declarations.single as T;
}
