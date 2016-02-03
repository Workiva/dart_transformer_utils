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

@TestOn('vm')
library transformer_utils.test.unit.node_with_meta_test;

import 'package:analyzer/analyzer.dart';
import 'package:test/test.dart';

import 'package:transformer_utils/transformer_utils.dart';

import '../test_utils.dart';

void main() {
  group('NodeWithMeta', () {
    test('instantiates and provides access to an annotation and node', () {
      var member = parseAndGetSingleMember('@TestAnnotation("hello")\nvar a;');
      var nodeWithMeta =
          new NodeWithMeta<TopLevelVariableDeclaration, TestAnnotation>(member);

      expect(nodeWithMeta.node, same(member));
      expect(nodeWithMeta.meta, isNotNull);
      expect(nodeWithMeta.meta.positional, 'hello');
    });
  });
}
