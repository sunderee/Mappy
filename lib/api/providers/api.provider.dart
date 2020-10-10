import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiProvider {
  final String baseURL;

  const ApiProvider({this.baseURL});

  Future<Map<String, dynamic>> makeGetRequest(
    String endpoint, {
    Map<String, String> queryParams,
    Map<String, String> headers,
  }) async {
    final http.Response response = await http.get(
      Uri.https(baseURL, endpoint, queryParams),
      headers: headers,
    );

    if (response.statusCode != 200) {
      return null;
    }

    return json.decode(response.body) as Map<String, dynamic>;
  }
}
