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
    return Scaffold(
      body: FutureBuilder(
        future: loadConfigFile(),
        builder: (
          BuildContext cntx,
          AsyncSnapshot<Map<String, dynamic>> snapshot,
        ) {
          if (snapshot.hasData) {
            final String token = snapshot.data['mapbox_api_token'] as String;
            return MapboxMap(
              accessToken: token,
              minMaxZoomPreference: MinMaxZoomPreference(6.0, 20.0),
              initialCameraPosition: CameraPosition(
                zoom: 15.0,
                target: LatLng(14.508, 46.048),
              ),
              onMapCreated: (MapboxMapController controller) async {
                final result = await acquireCurrentLocation();
                final animateCameraResult = await controller.animateCamera(
                  CameraUpdate.newLatLng(result),
                );
                if (animateCameraResult) {
                  await controller.addCircle(
                    CircleOptions(
                      circleRadius: 8.0,
                      circleColor: '#006992',
                      circleOpacity: 0.8,
                      geometry: result,
                      draggable: false,
                    ),
                  );
                }
              },
              onMapClick: (Point<double> point, LatLng coordinates) {
                BlocProvider.of<GeocodingBloc>(context)
                  ..add(
                    RequestGeocodingEvent(
                      latitude: coordinates.latitude,
                      longitude: coordinates.longitude,
                      mapboxApiKey: token,
                    ),
                  );
                _setupBottomModalSheet(cntx);
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
        onPressed: () {},
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
              return Wrap(
                children: [
                  ListTile(
                    title: Text('Coordinates'),
                    subtitle: Text(
                      'Lat/long: ${state.result.coordinates.latitude}/${state.result.coordinates.longitude}',
                    ),
                  ),
                  ListTile(
                    title: Text('Place name'),
                    subtitle: Text(state.result.placeName),
                  ),
                ],
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
