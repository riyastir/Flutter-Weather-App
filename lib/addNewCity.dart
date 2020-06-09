import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/models/newCities.dart';
import 'package:weatherapp/services/new_cities_service.dart';

class AddNewCity extends StatefulWidget {
  const AddNewCity({Key key}) : super(key: key);
  @override
  AddNewCityState createState() => AddNewCityState();
}

class AddNewCityState extends State<AddNewCity> {
  var _newCitiesService = CitiesService();
  String _mySelection;
  List apiCitiesData = List();
  String apiCityData;
  String _selectedCity = '';
  List<dynamic> newCityData;
  @override
  void initState() {
    //_dropdownMenuItems = buildDropDownMenuItems(_city);
    //_selectedCity = _dropdownMenuItems[0].value;
    super.initState();
    getAPICities();
  }

  Future<String> getAPICities() async {
    var apiCities =
        await http.get('https://alpha.riyas.co.in/api/weather/cities/');
    var jsonData = json.decode(apiCities.body);

    setState(() {
      apiCitiesData = jsonData;
    });

    print(jsonData);
    return 'Success';
  }

  Future<String> getCityData() async {
    final response =
        await http.get('https://alpha.riyas.co.in/api/weather/city/Ipoh');

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var jsonData = json.decode(response.body);
      setState(() {
        apiCityData = jsonData;
      });
      //await _newCitiesService.addNewCity(newCityId, newCityName, newCityLat, newCityLng);
      return 'Success';
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load city data');
    }
  }

  Future<dynamic> _addNewCitytoLocalDB(cityId) async{
    
    final response = await http.get('https://alpha.riyas.co.in/api/weather/city/$cityId');
    var jsonData = json.decode(response.body);
    //newCityData = jsonData;
    await _newCitiesService.addNewCity(jsonData['id']+3, jsonData['city'], jsonData['lat'], jsonData['lng']);
    setState(() {
      _selectedCity = jsonData['city'];

    });
    return 'Success';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.blue[900],
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0))),
          margin: EdgeInsets.fromLTRB(0, 200, 0, 0),
          padding: EdgeInsets.all(45.0),
          //height: 220,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: <Widget>[
              Text('Add City',
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
                items: apiCitiesData.map((item) {
                  return new DropdownMenuItem(
                    child: new Text(item['city'],
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20)),
                    value: item['id'].toString(),
                  );
                }).toList(),
                hint: Text('Select City',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20)),
                onChanged: (newVal) {
                  setState(() {
                    _mySelection = newVal;
                  });
                },
                value: _mySelection,
              ),
              RaisedButton(
                onPressed: ()=>_addNewCitytoLocalDB(this._mySelection),
                textColor: Colors.white,
                padding: const EdgeInsets.all(0.0),
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                  ),
                  padding: const EdgeInsets.all(10.0),
                  child: const Text('Add City', style: TextStyle(fontSize: 20)),
                ),
              ),
              //Text(_selectedCity),
            ],
          ),
        ),
      ]),
    );
  }
}

class NewCity {
  final int id;
  final String name;
  final double lat;
  final double lng;

  NewCity({this.id, this.name, this.lat, this.lng});

  factory NewCity.fromJson(Map<String, dynamic> json) {
    return NewCity(
      id: json['id'],
      name: json['name'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
