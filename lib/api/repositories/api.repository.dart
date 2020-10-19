import 'package:mappy/api/models/geocoding.model.dart';
import 'package:mappy/api/providers/api.provider.dart';
import 'package:mappy/api/repositories/iapi.repository.dart';

import '../../utils/helpers/config.helper.dart';

class ApiRepository implements IApiRepository {
  static final ApiRepository instance = ApiRepository._();
  final ApiProvider _provider = ApiProvider(baseURL: 'api.mapbox.com');
  ApiRepository._();

  @override
  Future<GeocodingModel> performGeocoding(
    double latitude,
    double longitude,
  ) async {
    final accessToken = (await loadConfigFile())['mapbox_api_token'];
    final result = await _provider.makeGetRequest(
      'geocoding/v5/mapbox.places/$longitude,$latitude.json',
      queryParams: {
        'types': 'region',
        'access_token': accessToken,
      },
    );
    return result != null ? GeocodingModel.fromJson(result) : GeocodingModel();
  }
}
