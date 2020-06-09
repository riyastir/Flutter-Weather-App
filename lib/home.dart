import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/services/new_cities_service.dart';

/// This Widget is the main application widget.
class Home extends StatefulWidget {
  static const String _title = 'Weather App';
  const Home({Key key}) : super(key: key);
  @override
  HomeState createState() => HomeState();
}

/// This is the stateless widget that the main application instantiates.
class HomeState extends State<Home> {
  Future<WeatherData> futureWeatherData;
  //List<City>  _city = City.getCity();
  // List<DropdownMenuItem<City>> _dropdownMenuItems;
  var _selectedCity;
  var _dbCities = List<DropdownMenuItem>();
  var _newCitiesService = CitiesService();
  
  @override
  void initState() {
    //_dropdownMenuItems = buildDropDownMenuItems(_city);
    //_selectedCity = _dropdownMenuItems[0].value;
    _getLocation().then((value) {
      print('Async done');
    });
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
    print('load Geo Function');
    var cities = await _newCitiesService.readCityByName(city);
    cities.forEach((city) {
      setState(() {
        futureWeatherData = fetchWeatherData(city['lat'], city['lng']);
      });
      print('lat');
      print(city['lat']);
      print('lng');
      print(city['lng']);
    });
  }

  List<DropdownMenuItem<City>> buildDropDownMenuItems(List cities) {
    List<DropdownMenuItem<City>> items = List();
    for (City city in cities) {
      items.add(
        DropdownMenuItem(
          value: city,
          child: Text(city.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20)),
        ),
      );
    }
    return items;
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
  }

  Future<WeatherData> fetchWeatherData(lat, lng) async {
    final response = await http.get(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=4e483e8711bcf08b3f0e7070da639d80&units=metric');
    print('api called');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      print('api success');
      return WeatherData.fromJson(json.decode(response.body));
    } else {
      print('api failed');
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load weather data');
    }
  }

  static const String _title = 'Weather App';
  onChangeCity(city) {
    setState(() {
      _selectedCity = city;
    });
    _loadGeoCodeFromDB(city);
    /*switch(city) {
      case 'Kuala Lumpur': {
        setState(() {
        futureWeatherData = fetchWeatherData(3.1390,101.6869);
      });
      }
      break;

      case 'George Town': {
        futureWeatherData = fetchWeatherData(5.411229,100.335426);
      }
      break;

      case 'Johor Bahru': {
        futureWeatherData = fetchWeatherData(1.4655,103.7578);
      }
      break;

      default: {
        //statements;
      }
      break;
    }*/
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
          // width: MediaQuery.of(context).size.width,
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
                //margin: EdgeInsets.all(20.0),

                height: 220,
                width: 600,
                //alignment: Alignment.center
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
                    DropdownButton(
                      iconEnabledColor: Colors.blue,
                      focusColor: Colors.blue[900],
                      value: _selectedCity,
                      items: _dbCities,
                      hint: Text('Select City',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 20)),
                      onChanged: onChangeCity,
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
                            width: 350,
                            //height: 300,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                            //width: 350,
                            //height: 300,
                            child: FutureBuilder<WeatherData>(
                              future: futureWeatherData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data.title,
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 30));
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                // By default, show a loading spinner.
                                return Container(
                                    width: 300,
                                    //height: 80,
                                    color: Colors.white,
                                    padding: EdgeInsets.all(20.0),
                                    child: Row(
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            new CircularProgressIndicator(
                                              backgroundColor: Colors.blue[900],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                      30.0, 0, 0, 0),
                                              child: Text("Please Wait"),
                                            ),
                                            //new Text('Loading',textAlign: TextAlign.center),
                                          ],
                                        ),
                                      ],
                                    ));
                              },
                            ),
                            //child: Text('Kuala Lumpur',textDirection: TextDirection.ltr,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 30 )),
                          ),
                          new Container(
                            padding: EdgeInsets.all(20.0),
                            width: 350,
                            height: 150,
                            child: FutureBuilder<WeatherData>(
                              future: futureWeatherData,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data.temp + '\u00B0C',
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 80));
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }
                                return Text('');
                              },
                            ),
                            //child: new Text('34\u00B0C',textDirection: TextDirection.ltr,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 80 )),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
             
            ],
          ),
        );
  }
}

class WeatherData {
  final String temp;
  final int id;
  final String title;

  WeatherData({this.temp, this.id, this.title});

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      temp: json['main']['temp'].toString(),
      id: json['id'],
      title: json['name'],
    );
  }
}

class City {
  int id;
  String name;

  City(this.id, this.name);

  static List<City> getCity() {
    return <City>[
      City(1, 'Kuala Lumpur'),
      City(2, 'George Town'),
      City(3, 'Johor Bahru'),
    ];
  }
}
