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
library transformer_utils.test.unit.jet_brains_friendly_logger_test;

import 'package:barback/barback.dart';
import 'package:mockito/mockito.dart';
import 'package:source_span/source_span.dart';
import 'package:test/test.dart';
import 'package:transformer_utils/src/jet_brains_friendly_logger.dart';

main() {
  group('JetBrainsFriendlyLogger', () {
    MockTransformLogger mockWrappedLogger;
    JetBrainsFriendlyLogger logger;

    setUp(() {
      mockWrappedLogger = new MockTransformLogger();
      logger = new JetBrainsFriendlyLogger(mockWrappedLogger);
    });

    group('clickableReference()', () {
      test('returns a properly-formatted reference to a source span', () {
        var lines = ['line 1', 'line 2 TARGET', 'line 3'];
        var sourceFile = new SourceFile(lines.join('\n'), url: 'source_url');
        var span = sourceFile.span(sourceFile.getText(0).indexOf('TARGET'));
        var formatted = JetBrainsFriendlyLogger.clickableReference(span);
        expect(formatted, '[source_url 2:8]: ');
      });

      test('returns an empty string when the specified span is null', () {
        expect(JetBrainsFriendlyLogger.clickableReference(null), '');
      });
    });

    group('highlightedSpanText()', () {
      test('returns the highlighted text of a source span', () {
        var lines = ['line 1', 'line 2 TARGET', 'line 3'];
        var sourceFile = new SourceFile(lines.join('\n'), url: 'source_url');
        int targetIndex = sourceFile.getText(0).indexOf('TARGET');
        var span = sourceFile.span(targetIndex, targetIndex + 'TARGET'.length);
        expect(span.text, 'TARGET',
            reason: 'should have set up the test as expected');

        var expectedLines = [
          'line 2 TARGET',
          '       ^^^^^^' // should underline "TARGET"
        ];
        expect(JetBrainsFriendlyLogger.highlightedSpanText(span),
            expectedLines.join('\n'));
      });
    });

    group('proxies logs methods,', () {
      SourceSpan span;
      String spanReference;
      String highlightedSpan;
      AssetId asset;
      String message;

      setUp(() {
        var sourceFile = new SourceFile('source file');

        span = sourceFile.span(0);
        spanReference = JetBrainsFriendlyLogger.clickableReference(span);
        highlightedSpan = JetBrainsFriendlyLogger.highlightedSpanText(span);
        asset = new AssetId('package', 'path');
        message = 'message';
      });

      group('prepends the message with the formatted source span', () {
        test('info()', () {
          logger.info(message, asset: asset, span: span);
          verify(mockWrappedLogger
              .info('$spanReference$message\n$highlightedSpan', asset: asset));
        });

        test('fine()', () {
          logger.fine(message, asset: asset, span: span);
          verify(mockWrappedLogger
              .fine('$spanReference$message\n$highlightedSpan', asset: asset));
        });

        test('warning()', () {
          logger.warning(message, asset: asset, span: span);
          verify(mockWrappedLogger.warning(
              '$spanReference$message\n$highlightedSpan',
              asset: asset));
        });

        test('error()', () {
          logger.error(message, asset: asset, span: span);
          verify(mockWrappedLogger
              .error('$spanReference$message\n$highlightedSpan', asset: asset));
        });
      });

      group('leaves the message as-is when a span is not specified', () {
        test('info()', () {
          logger.info(message, asset: asset);
          verify(mockWrappedLogger.info(message, asset: asset));
        });

        test('fine()', () {
          logger.fine(message, asset: asset);
          verify(mockWrappedLogger.fine(message, asset: asset));
        });

        test('warning()', () {
          logger.warning(message, asset: asset);
          verify(mockWrappedLogger.warning(message, asset: asset));
        });

        test('error()', () {
          logger.error(message, asset: asset);
          verify(mockWrappedLogger.error(message, asset: asset));
        });
      });
    });
  });
}

class MockTransformLogger extends Mock implements TransformLogger {
  noSuchMethod(i) => super.noSuchMethod(i);
}
