import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/services/new_cities_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:weatherapp/models/weatherData.dart';
import 'package:weatherapp/provider/stateprovider.dart';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  Future<WeatherData> futureWeatherData;
  var _dbCities = List<DropdownMenuItem>();
  var _newCitiesService = CitiesService();
  bool isLoading = false;

  @override
  void initState() {
    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    stateProvider.setCity == true
        ? _loadGeoCodeFromDB(stateProvider.selectedCity)
        : _getLocation();
    super.initState();
    _loadDBCities();
  }

  _loadDBCities() async {
    var cities = await _newCitiesService.readCities();
    cities.forEach((city) {
      setState(() {
        _dbCities.add(DropdownMenuItem(
          child: Text(city['name'],
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20)),
          value: city['name'],
        ));
      });
    });
  }

  _loadGeoCodeFromDB(city) async {
    var cities = await _newCitiesService.readCityByName(city);

    cities.forEach((city) {
      setState(() {
        futureWeatherData = fetchWeatherData(city['lat'], city['lng']);
      });
    });
    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    stateProvider.finishChange();
  }

  final Location location = Location();

  LocationData _location;
  String _error;

  Future<void> _getLocation() async {
    setState(() {
      _error = null;
    });
    try {
      final LocationData _locationResult = await location.getLocation();
      setState(() {
        _location = _locationResult;
        futureWeatherData =
            fetchWeatherData(_location.latitude, _location.longitude);
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
    print(_error);
  }

  Future<WeatherData> fetchWeatherData(lat, lng) async {
    setState(() {
      isLoading = true;
    });
    final response = await http.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=4e483e8711bcf08b3f0e7070da639d80&units=metric');

    if (response.statusCode == 200) {
      setState(() {
        isLoading = false;
      });
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load weather data');
    }
  }

  @override
  Widget build(BuildContext context) {
    final stateProvider = Provider.of<StateProvider>(context);
    stateProvider.cityChange == 1
        ? _loadGeoCodeFromDB(stateProvider.selectedCity)
        : Container();
    return LoadingOverlay(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            child: Container(
              child: new Column(
                children: <Widget>[
                  new Container(
                    decoration: BoxDecoration(
                        color: Colors.blue[900],
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(50.0),
                            bottomRight: Radius.circular(50.0))),
                    padding: EdgeInsets.all(45.0),
                    height: 220,
                    width: MediaQuery.of(context).size.width,
                    child: new Column(
                      children: <Widget>[
                        new Text('Select City',
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 50)),
                        SizedBox(
                          height: 20.0,
                        ),
                        Consumer<StateProvider>(
                          builder: (context, data, child) {
                            return DropdownButton(
                              iconEnabledColor: Colors.blue,
                              focusColor: Colors.blue[900],
                              value: data.selectedCity,
                              items: _dbCities,
                              hint: Text('Select City',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 20)),
                              onChanged: data.onChangeCity,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    padding: EdgeInsets.all(10.0),
                    child: new Column(
                      children: <Widget>[
                        new Card(
                          margin: EdgeInsets.all(20.0),
                          color: Colors.blue[900],
                          child: Column(
                            children: <Widget>[
                              new Container(
                                padding: EdgeInsets.all(10.0),
                                width: MediaQuery.of(context).size.width,
                                height: MediaQuery.of(context).size.height/8,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: const <Widget>[
                                    Icon(
                                      Icons.cloud,
                                      color: Colors.white,
                                      size: 50.0,
                                    ),
                                  ],
                                ),
                              ),
                              new Container(
                                padding: EdgeInsets.all(10.0),
                                child: FutureBuilder<WeatherData>(
                                  future: futureWeatherData,
                                  builder: (context, weather) {
                                    if (weather.hasData) {
                                      return Text(weather.data.title,
                                          textDirection: TextDirection.ltr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 30));
                                    } else if (weather.hasError) {
                                      return Text("${weather.error}");
                                    }
                                    return Container();
                                  },
                                ),
                              ),
                              new Container(
                                padding: EdgeInsets.all(20.0),
                                width: 350,
                                height: 150,
                                child: FutureBuilder<WeatherData>(
                                  future: futureWeatherData,
                                  builder: (context, weather) {
                                    if (weather.hasData) {
                                      return Text(
                                          weather.data.temp + '\u00B0C',
                                          textDirection: TextDirection.ltr,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 70));
                                    } else if (weather.hasError) {
                                      return Text("${weather.error}");
                                    }
                                    return Text('');
                                  },
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        isLoading: isLoading,
        opacity: 0.5,
        progressIndicator: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                width: 300,
                padding: EdgeInsets.all(20.0),
                color: Colors.white,
                margin: EdgeInsets.fromLTRB(50.0, 0, 0, 0),
                child: Row(
                  children: <Widget>[
                    CircularProgressIndicator(
                        backgroundColor: Colors.blue[900]),
                    Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(30.0, 0, 0, 0),
                          child: Text("Loading"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
