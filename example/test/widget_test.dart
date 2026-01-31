// Main test runner for ui_eval example app
import 'package:flutter_test/flutter_test.dart';

import 'widgets/counter_app_test.dart' as counter_app;
import 'widgets/bundle_loader_test.dart' as bundle_loader;
import 'widgets/counter_integration_test.dart' as integration;

void main() {
  group('All Widget Tests', () {
    counter_app.main();
    bundle_loader.main();
    integration.main();
  });
}
