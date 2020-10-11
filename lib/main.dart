import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:mappy/blocs/geocoding.bloc.dart';
import 'package:mappy/blocs/geocoding.event.dart';
import 'package:mappy/blocs/geocoding.state.dart';
import 'package:mappy/utils/config.helper.dart';
import 'package:mappy/utils/location.helper.dart';

void main() {
  runApp(
    BlocProvider(
      create: (BuildContext context) => GeocodingBloc(),
      child: App(),
    ),
  );
}

const Color COLOR_PRIMARY = const Color(0xFFFBFAF8);
const Color COLOR_SECONDARY = const Color(0xFFF4F4F8);
const Color COLOR_ACCENT = const Color(0xFF006992);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: COLOR_PRIMARY,
        accentColor: COLOR_ACCENT,
        scaffoldBackgroundColor: COLOR_SECONDARY,
        appBarTheme: AppBarTheme(
          elevation: 0.0,
          color: COLOR_SECONDARY,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MapboxMapController _mapController;
    return Scaffold(
      body: FutureBuilder(
        future: loadConfigFile(),
        builder: (
          BuildContext cntx,
          AsyncSnapshot<Map<String, dynamic>> snapshot,
        ) {
          if (snapshot.hasData) {
            final String token = snapshot.data['mapbox_api_token'] as String;
            final String style = snapshot.data['mapbox_style_url'] as String;
            return MapboxMap(
              accessToken: token,
              styleString: style,
              minMaxZoomPreference: const MinMaxZoomPreference(6.0, null),
              initialCameraPosition: CameraPosition(
                zoom: 15.0,
                target: LatLng(14.508, 46.048),
              ),
              onMapCreated: (MapboxMapController controller) async {
                _mapController = controller;
                final result = await acquireCurrentLocation();
                await controller.animateCamera(
                  CameraUpdate.newLatLng(result),
                );

                await controller.addCircle(
                  CircleOptions(
                    circleRadius: 8.0,
                    circleColor: '#006992',
                    circleOpacity: 0.8,
                    geometry: result,
                    draggable: false,
                  ),
                );
              },
              onMapClick: (Point<double> point, LatLng coordinates) {
                BlocProvider.of<GeocodingBloc>(context)
                  ..add(
                    RequestGeocodingEvent(
                      latitude: coordinates.latitude,
                      longitude: coordinates.longitude,
                    ),
                  );
                _setupBottomModalSheet(cntx);
              },
              onMapLongClick: (Point<double> point, LatLng coordinates) async {
                await _mapController.addSymbol(
                  SymbolOptions(
                    iconImage: 'embassy-15',
                    iconColor: '#006992',
                    geometry: coordinates,
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 16.0,
                  ),
                  Text('Error has occurred: ${snapshot.error.toString()}')
                ],
              ),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.location_on_sharp),
        onPressed: () async {
          final result = await acquireCurrentLocation();
          _mapController.animateCamera(CameraUpdate.newLatLng(result));
        },
      ),
    );
  }

  void _setupBottomModalSheet(BuildContext buildContext) {
    showModalBottomSheet(
      context: buildContext,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return BlocBuilder<GeocodingBloc, GeocodingState>(
          builder: (BuildContext cntx, GeocodingState state) {
            if (state is LoadingGeocodingState) {
              return Container(
                height: 158.0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 16.0,
                      ),
                      Text('Loading results')
                    ],
                  ),
                ),
              );
            } else if (state is SuccessfulGeocodingState) {
              final latitudeString =
                  state.result.coordinates.latitude.toStringAsPrecision(5);
              final longitudeString =
                  state.result.coordinates.longitude.toStringAsPrecision(5);
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  children: [
                    ListTile(
                      title: Text('Coordinates (latitude/longitude)'),
                      subtitle: Text(
                        '$latitudeString/$longitudeString',
                      ),
                    ),
                    ListTile(
                      title: Text('Place name'),
                      subtitle: Text(state.result.placeName),
                    ),
                  ],
                ),
              );
            } else if (state is FailedGeocodingState) {
              return ListTile(
                title: Text('Error'),
                subtitle: Text(state.error),
              );
            } else {
              return ListTile(
                title: Text('Error'),
                subtitle: Text('Unknown error'),
              );
            }
          },
        );
      },
    );
  }
}
