import 'dart:convert';
import 'package:flutter/services.dart';

const String _CONFIG_FILE_PATH = 'assets/config.json';

Future<Map<String, dynamic>> loadConfigFile() async {
  String jsonString = await rootBundle.loadString(_CONFIG_FILE_PATH);
  return jsonDecode(jsonString) as Map<String, dynamic>;
}
