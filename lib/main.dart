import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mappy/blocs/geocoding.bloc.dart';
import 'package:mappy/ui/app.dart';

void main() {
  runApp(
    BlocProvider(
      create: (BuildContext context) => GeocodingBloc(),
      child: App(),
    ),
  );
}
