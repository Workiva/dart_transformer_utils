library tool.dev;

import 'package:dart_dev/dart_dev.dart' show dev, config;

main(List<String> args) async {
  // https://github.com/Workiva/dart_dev

  config.analyze.entryPoints = ['lib/', 'test/', 'test/unit/'];
  config.format.directories = ['lib/', 'test/'];
  config.test.unitTests = ['test/unit/'];

  await dev(args);
}
