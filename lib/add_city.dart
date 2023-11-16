import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherApi {
  static Future<List<String>> searchCities(String query) async {
    final apiKey = 'a8da451bcf3a9d4c44c07d1650b061ed'; // Replace with your actual API key
    final apiUrl = 'https://api.openweathermap.org/data/2.5/find';

    final response = await http.get(
      Uri.parse('$apiUrl?q=$query&appid=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> cityList = data['list'];

      return cityList.map((city) => city['name'].toString()).toList();
    } else {
      print('Failed to load cities: ${response.statusCode}');
      return [];
    }
  }
}
