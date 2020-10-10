import 'package:mapbox_gl/mapbox_gl.dart';

class GeocodingModel {
  LatLng coordinates;
  String placeName;

  GeocodingModel({this.coordinates, this.placeName = ''});

  GeocodingModel.fromJson(Map<String, dynamic> json) {
    List<dynamic> queryResult = json['query'];
    this.coordinates = LatLng(
      queryResult[0],
      queryResult[1],
    );
    this.placeName = json['features'][0]['place_name'];
  }

  @override
  String toString() => '$runtimeType: ${coordinates.toJson()}, $placeName';
}
