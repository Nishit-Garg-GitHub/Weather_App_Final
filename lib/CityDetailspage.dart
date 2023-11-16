import 'package:flutter/material.dart';

class CityDetailsPage extends StatelessWidget {
  final String cityName;

  CityDetailsPage({required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cityName),
      ),
      body: Center(
        child: Text('Details for $cityName'),
      ),
    );
  }
}
