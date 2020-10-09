import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

const Color COLOR_PRIMARY = const Color(0xFFFBFAF8);
const Color COLOR_SECONDARY = const Color(0xFFF4F4F8);
const Color COLOR_ACCENT = const Color(0xFF006992);

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    return Scaffold();
  }
}
