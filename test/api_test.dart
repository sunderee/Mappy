import 'package:flutter_test/flutter_test.dart';
import 'package:mappy/api/repositories/api.repository.dart';
import 'package:mappy/utils/config.helper.dart';

void main() {
  group('testing Mapbox API', () {
    test('geocoding result', () async {
      final repository = ApiRepository.instance;
      final configFile = await loadConfigFile();
      final result = await repository.performGeocoding(
        45.45,
        45.45,
        configFile['mapbox_api_token'] as String,
      );

      print(result.toString());
      expect(result.placeName.isNotEmpty, true);
    });
  });
}
