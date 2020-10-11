abstract class GeocodingEvent {
  const GeocodingEvent();
}

class RequestGeocodingEvent extends GeocodingEvent {
  final double latitude;
  final double longitude;

  const RequestGeocodingEvent({
    this.latitude = 0.0,
    this.longitude = 0.0,
  });
}
