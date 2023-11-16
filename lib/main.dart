import 'package:flutter/material.dart';
import 'weather_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'add_city.dart';
import 'login_page.dart';
import 'dart:convert';
import 'dart:io';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      primaryColor: Colors.blue,
      fontFamily: 'Roboto',
    ),
    home: WeatherHomePage(defaultCity: 'Pilani'),
  ),
);

class WeatherHomePage extends StatefulWidget {
  final String defaultCity;

  WeatherHomePage({required this.defaultCity});

  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  WeatherService weatherService = WeatherService();
  Map<String, dynamic> weatherData = {};
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchWeatherData(widget.defaultCity);
  }

  Future<void> fetchWeatherData(String city) async {
    try {
      setState(() {
        isLoading = true;
      });
      weatherData = await weatherService.getWeatherData(city);
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (weatherData.isEmpty) {
      return Scaffold(body: Center(child: Text('Failed to load weather data')));
    } else {
      final temperature = (weatherData['main']['temp']) - 273.15;
      final weatherCondition = weatherData['weather'][0]['description'];
      final capitalizedWeatherCondition =
          weatherCondition[0].toUpperCase() + weatherCondition.substring(1);

      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageCitiesPage(),
                ),
              );
            },
          ),
          title: Center(
            child: Text('Weather App'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {},
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://static.vecteezy.com/system/resources/thumbnails/011/689/764/small/dark-grey-cloud-in-cloudy-sky-photo.jpg',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(height: 40),
                Text(
                  widget.defaultCity,
                  style: TextStyle(fontSize: 35.0, color: Colors.black),
                ),
                Text(
                  '${temperature.toStringAsFixed(0)}°C',
                  style: TextStyle(fontSize: 65.0, color: Colors.black),
                ),

                Text(
                  capitalizedWeatherCondition,
                  style: TextStyle(fontSize: 20.0, color: Colors.black),
                ),
                Text('🥽 AQI 165',
                    style: TextStyle(fontSize: 14.0, color: Colors.black)),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.all(3),
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'More Details>',
                      style: TextStyle(fontSize: 15.0, color: Colors.blue),
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: <Widget>[
                        WeatherInfoRow('Today', 'Haze 40°/23°'),
                        WeatherInfoRow('Tomorrow', 'Haze 40°/23°'),
                        WeatherInfoRow('Sunday', 'Haze 40°/23°'),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 60),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FiveDayForecastPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.blue,
                        ),
                        child: Text(
                          "5-day forecast",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    WeatherDataRow('Now', '15:00', '16:00', '17:00'),
                    WeatherDataRow('39°', '39°', '40°', '39°'),
                    WeatherDataRow('☁', '☁', '☁', '☁'),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}

class WeatherInfoRow extends StatelessWidget {
  final String day;
  final String forecast;

  WeatherInfoRow(this.day, this.forecast);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              day,
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Text(
              forecast,
              style: TextStyle(fontSize: 18.0, color: Colors.black),
            ),
          ],
        ));
  }
}

class WeatherDataRow extends StatelessWidget {
  final String time1;
  final String time2;
  final String time3;
  final String time4;

  WeatherDataRow(this.time1, this.time2, this.time3, this.time4);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            time1,
            style: TextStyle(fontSize: 15.0, color: Colors.black),
          ),
          Text(
            time2,
            style: TextStyle(fontSize: 15.0, color: Colors.black),
          ),
          Text(
            time3,
            style: TextStyle(fontSize: 15.0, color: Colors.black),
          ),
          Text(
            time4,
            style: TextStyle(fontSize: 15.0, color: Colors.black),
          ),
        ]);
  }
}

class ManageCitiesPage extends StatefulWidget {
  @override
  _ManageCitiesPageState createState() => _ManageCitiesPageState();
}

class _ManageCitiesPageState extends State<ManageCitiesPage> {
  TextEditingController _searchController = TextEditingController();
  List<String> cities = [];
  List<String> userAddedCities = [];

  Future<void> searchCities(String query) async {
    List<String> results = await WeatherApi.searchCities(query);
    setState(() {
      cities = results;
    });
  }

  String getTemperatureForCity(String city) {
    return '25';
  }

  void addCity(String city) {
    setState(() {
      userAddedCities.add(city);
    });
  }

  void onCitySelected(String selectedCity) {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WeatherHomePage(defaultCity: selectedCity),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Manage Cities'),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (query) {
                searchCities(query);
              },
              decoration: InputDecoration(
                hintText: 'Search for cities...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 20),
                Container(
                  height: 80,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            color: Colors.blue,
                            child: Center(
                              child: Text(
                                "Pilani",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Container(
                  height: 80,
                  margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      primary: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: Row(
                      children: [

                        Expanded(
                          child: Container(
                            color: Colors.blue,
                            child: Center(
                              child: Text(
                                "Delhi",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                for (String city in cities)
                  Card(
                    elevation: 2.0,
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: ListTile(
                      title: Text(city),
                      subtitle: Text('Temperature: ${getTemperatureForCity(city)}°C'),
                      onTap: () {
                        onCitySelected(city);
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          addCity(city);
                        },
                      ),
                    ),
                  ),


                for (String city in userAddedCities)
                  Card(
                    elevation: 2.0,
                    margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                    child: ListTile(
                      title: Text(city),
                      subtitle: Text('Temperature: ${getTemperatureForCity(city)}°C'),
                      onTap: () {
                        onCitySelected(city);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}







class FiveDayForecastPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Center(
          child: Text(
            '5-Day Forecast',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildDayColumn('Today', '6/10', Icons.cloud_outlined, Icons.mode_night_sharp, '→23.5km/h'),
                    buildDayColumn('Tomorrow', '7/10', Icons.cloud_outlined, Icons.mode_night_sharp, '↗18.5km/h'),
                    buildDayColumn('Sun', '8/10', Icons.cloud_outlined, Icons.mode_night_sharp, '→18.5km/h'),
                    buildDayColumn('Thu', '8/10', Icons.cloud_outlined, Icons.mode_night_sharp, '↗18.5km/h'),
                    buildDayColumn('Mon', '9/10', Icons.cloud_outlined, Icons.mode_night_sharp, '↗18.5km/h'),
                  ],
                ),
              ),
            ),


            Container(
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Max and Min Temparatures',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),


            SizedBox(height: 150),


            buildLineChart([40, 36, 36, 36, 36], Colors.red, minY: -5, maxY: 45),
            buildLineChart([23, 24, 25, 25, 22], Colors.blue, minY: 0, maxY: 30),
          ],
        ),
      ),
    );
  }

  Widget buildDayColumn(String day, String rating, IconData weatherIcon, IconData nightIcon, String wind) {
    return Column(
      children: [
        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(day),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(rating),
          ],
        ),
        SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(weatherIcon),
          ],
        ),
        SizedBox(height: 50),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(nightIcon),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(wind, style: TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  Widget buildLineChart(List<double> data, Color color, {double minY = 0, double maxY = 50}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: SizedBox(
        height: 100,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(show: true),
            titlesData: FlTitlesData(show: false),
            borderData: FlBorderData(show: true),
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(data.length, (index) => FlSpot(index.toDouble(), data[index])),
                isCurved: false,
                belowBarData: BarAreaData(show: false),
                colors: [color],
                dotData: FlDotData(show: true),
              ),
            ],
            minY: minY,
            maxY: maxY,
          ),
        ),
      ),
    );
  }
}





