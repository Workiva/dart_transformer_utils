library transformer_utils.src.analyzer_helpers;

import 'dart:mirrors' as mirrors;

import 'package:analyzer/analyzer.dart';

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
