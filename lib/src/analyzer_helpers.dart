library transformer_utils.src.analyzer_helpers;

import 'dart:mirrors' as mirrors;

import 'package:analyzer/analyzer.dart';
import 'package:barback/barback.dart';

import 'package:transformer_utils/src/node_with_meta.dart';

/// Returns a copy of a class [member] declaration with [body] as a new
/// implementation.
///
/// Currently only supports:
///   * [FieldDeclaration] (single variable only)
///   * [MethodDeclaration] (getter, setter, and methods)
String copyClassMember(ClassMember member, String body) {
  if (member is FieldDeclaration) return _copyFieldDeclaration(member, body);
  if (member is MethodDeclaration) {
    if (member.isGetter) return _copyGetterDeclaration(member, body);
    if (member.isSetter) return _copySetterDeclaration(member, body);
    return _copyMethodDeclaration(member, body);
  }
  throw new UnsupportedError(
      'Unsupported class member type: ${member.runtimeType}. '
      'Only FieldDeclaration and MethodDeclaration are supported.');
}

/// Finds and returns all declarations within a compilation [unit] that are
/// annotated with the given [annotation] class.
///
/// If this is being leveraged within a transformer, you can associate the
/// returned [DeclarationWithMeta] instance with the asset in which it is
/// located by passing in an [assetId].
Iterable<NodeWithMeta> getDeclarationsAnnotatedBy(
    CompilationUnit unit, Type annotation,
    {AssetId assetId}) {
  var annotationName = _getReflectedName(annotation);
  return unit.declarations.where((member) {
    return member.metadata.any((meta) => meta.name.name == annotationName);
  }).map((member) => new NodeWithMeta(member, assetId: assetId));
}

/// Given a [literal] (an AST node), this returns the literal's value.
///
/// Currently only supports:
///   * [StringLiteral]
///   * [BooleanLiteral]
///   * [IntegerLiteral]
///   * [NullLiteral]
dynamic getLiteralValue(Literal literal) {
  if (literal is StringLiteral) {
    var value = literal.stringValue;
    if (value == null)
      throw new UnsupportedError('Unsupported literal: $literal. '
          'Must be a non-interpolated string.');
    return value;
  } else if (literal is BooleanLiteral) {
    return literal.value;
  } else if (literal is IntegerLiteral) {
    return literal.value;
  } else if (literal is NullLiteral) {
    return null;
  }

  throw new UnsupportedError('Unsupported literal: $literal.'
      'Must be a string, boolean, integer, or null literal');
}

/// Using reflection, this instantiates and returns the first annotation on
/// [member] of type [annotationType], or null if no matching annotations are
/// found.
///
/// Annotation constructors are currently limited to the values supported by
/// [getLiteralValue].
///
/// Naively assumes that the name of the [annotationType] class is canonical.
dynamic instantiateAnnotation(AnnotatedNode member, Type annotationType) {
  // Be sure to use `originalDeclaration` so that generic parameters work.
  mirrors.ClassMirror classMirror =
      mirrors.reflectClass(annotationType).originalDeclaration;
  String className = mirrors.MirrorSystem.getName(classMirror.simpleName);

  // Find the annotation that matches [type]'s name.
  Annotation matchingAnnotation = member.metadata.firstWhere((annotation) {
    return _getClassName(annotation) == className;
  }, orElse: () => null);

  // If no annotation is found, return null.
  if (matchingAnnotation == null) {
    return null;
  }

  if (matchingAnnotation.arguments == null) {
    throw 'Annotation not invocation of constructor: `$matchingAnnotation`. '
        'This is likely due to invalid usage of the annotation class, but could'
        'also be a name conflict with the specified type `$annotationType`';
  }

  // Get the parameters from the annotation's AST.
  Map namedParameters = {};
  List positionalParameters = [];

  matchingAnnotation.arguments.arguments.forEach((expression) {
    if (expression is NamedExpression) {
      var name = (expression as NamedExpression).name.label.name;
      var value = getLiteralValue((expression as NamedExpression).expression);

      namedParameters[new Symbol(name)] = value;
    } else {
      var value = getLiteralValue(expression);

      positionalParameters.add(value);
    }
  });

  // Instantiate and return an instance of the annotation using reflection.
  String constructorName = _getConstructorName(matchingAnnotation) ?? '';

  try {
    var instanceMirror = classMirror.newInstance(
        new Symbol(constructorName), positionalParameters, namedParameters);
    return instanceMirror.reflectee;
  } catch (e) {
    throw 'Unable to instantiate annotation: $matchingAnnotation. This is '
        'likely due to improper usage, or a naming conflict with '
        'annotationType $annotationType. Original error: $e.';
  }
}

String _copyFieldDeclaration(FieldDeclaration decl, String initializer) {
  var result = '';
  if (decl.fields.type != null) {
    result = '${decl.fields.type}';
  } else if (decl.staticKeyword == null) {
    result = 'var';
  }
  if (decl.staticKeyword != null) {
    result = '${decl.staticKeyword} $result';
  }
  result = '$result ${decl.fields.variables.first.name.name}';
  if (initializer != null && initializer.isNotEmpty) {
    result = '$result = $initializer;';
  } else {
    result = '$result;';
  }
  return result;
}

String _copyGetterDeclaration(MethodDeclaration decl, String body) {
  bool isAsync =
      decl.returnType != null && decl.returnType.name.name == 'Future';
  var result = '';
  if (decl.returnType != null) {
    result = '${decl.returnType} get';
  } else {
    result = 'get';
  }
  if (decl.isStatic) {
    result = 'static $result';
  }
  if (isAsync) {
    result = '$result async';
  }
  result = '$result ${decl.name.name} {\n$body\n  }';
  return result;
}

String _copySetterDeclaration(MethodDeclaration decl, String body) {
  var result = 'void set';
  if (decl.isStatic) {
    result = 'static $result';
  }
  result = '$result ${decl.name.name}${decl.parameters} {\n$body\n  }';
  return result;
}

String _copyMethodDeclaration(MethodDeclaration decl, String body) {
  bool isAsync =
      decl.returnType != null && decl.returnType.name.name == 'Future';
  var result = '${decl.name.name}';
  if (decl.returnType != null) {
    result = '${decl.returnType} $result';
  }
  if (decl.isStatic) {
    result = 'static $result';
  }
  if (decl.parameters != null) {
    result = '$result${decl.parameters}';
  } else {
    result = '$result()';
  }
  if (isAsync) {
    result = '$result async';
  }
  result = '$result {\n$body\n  }';
  return result;
}

/// Returns the name of the class being instantiated for [annotation], or null
/// if the annotation is not the invocation of a constructor.
///
/// Workaround for a Dart analyzer issue where the constructor name is included
/// in [annotation.name].
String _getClassName(Annotation annotation) {
  var className = annotation.name?.name;
  if (className != null) {
    className = className.split('.').first;
  }

  return className;
}

/// Returns the name of the constructor being instantiated for [annotation], or
/// null if the annotation is not the invocation of a named constructor.
///
/// Workaround for a Dart analyzer issue where the constructor name is included
/// in [annotation.name].
String _getConstructorName(Annotation annotation) {
  var constructorName = annotation.constructorName?.name;
  if (constructorName == null) {
    var periodIndex = annotation.name.name.indexOf('.');
    if (periodIndex != -1) {
      constructorName = annotation.name.name.substring(periodIndex + 1);
    }
  }

  return constructorName;
}

/// Get the name of a [type] via reflection.
String _getReflectedName(Type type) =>
    mirrors.MirrorSystem.getName(mirrors.reflectType(type).simpleName);
