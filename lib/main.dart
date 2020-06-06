// Flutter code sample for Card

// This sample shows creation of a [Card] widget that shows album information
// and two actions.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;



void main() => runApp(MyApp());


/// This Widget is the main application widget.
class MyApp extends StatefulWidget{
  static const String _title = 'Weather App';
  const MyApp({Key key}) : super(key: key);
  @override
  MyAppState createState() => MyAppState();
}

/// This is the stateless widget that the main application instantiates.
class MyAppState extends State<MyApp> {
  Future<Album> futureAlbum;

  @override
  void initState() {
    _getLocation().then((value){
      print('Async done');
    });
    super.initState();
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
        futureAlbum = fetchAlbum(_location.latitude,_location.longitude);
      });
    } on PlatformException catch (err) {
      setState(() {
        _error = err.code;
      });
    }
  }

  Future<Album> fetchAlbum(lat,lng) async {
    final response = await http.get('https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lng&appid=4e483e8711bcf08b3f0e7070da639d80&units=metric');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Album.fromJson(json.decode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album');
    }
  }
  static const String _title = 'Weather App';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        //appBar: AppBar(title: const Text(_title)),
        body: Container(
          child: new Column(
            children: <Widget>[
              new Container(
                decoration: BoxDecoration(
                    color: Colors.blue[900],
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(50.0),
                        bottomRight: Radius.circular(50.0)
                    )
                ),
                padding: EdgeInsets.all(45.0),
                //margin: EdgeInsets.all(20.0),

                height:200,
                width: 600,
                //alignment: Alignment.center
                child: new Column(
                  children: <Widget>[
                    new Text('Your Location',textDirection: TextDirection.ltr,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 50 )),
                    new DropdownButton<String>(
                      items: <String>['Kuala Lumpur', 'George Town', 'Johor Bahru'].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                      onChanged: (_) {},
                    ),
                  ],
                ),
              ),
              new Container(
                padding: EdgeInsets.all(10.0),
                child: new Column(
                  children: <Widget>[
                    new Card(
                      margin: EdgeInsets.all(40.0),
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
                            width: 350,
                            //height: 300,
                            child: FutureBuilder<Album>(
                              future: futureAlbum,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data.title,textDirection: TextDirection.ltr,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 30 ));
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }

                                // By default, show a loading spinner.
                                return CircularProgressIndicator();
                              },
                            ),
                            //child: Text('Kuala Lumpur',textDirection: TextDirection.ltr,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 30 )),
                          ),
                          new Container(
                            padding: EdgeInsets.all(20.0),
                            width: 350,
                            height: 150,
                            child: FutureBuilder<Album>(
                              future: futureAlbum,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return Text(snapshot.data.temp+'\u00B0C',textDirection: TextDirection.ltr,textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white,fontSize: 80 ));
                                } else if (snapshot.hasError) {
                                  return Text("${snapshot.error}");
                                }

                                // By default, show a loading spinner.
                                return CircularProgressIndicator();
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
        ),
      ),
    );
  }
}
class Album {
  final String temp;
  final int id;
  final String title;

  Album({this.temp, this.id, this.title});

  factory Album.fromJson(Map<String, dynamic> json) {
    return Album(
      temp: json['main']['temp'].toString(),
      id: json['id'],
      title: json['name'],
    );
  }
}

