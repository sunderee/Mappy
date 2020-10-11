import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mappy/api/repositories/api.repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() => HttpOverrides.global = null);

  group('testing Mapbox API', () {
    test('geocoding result', () async {
      final repository = ApiRepository.instance;
      final result = await repository.performGeocoding(
        45.45,
        45.45,
      );

      print(result.toString());
      expect(result.placeName.isNotEmpty, true);
    });
  });
}
