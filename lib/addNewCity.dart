import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weatherapp/services/new_cities_service.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:weatherapp/provider/stateprovider.dart';

class AddNewCity extends StatefulWidget {
  const AddNewCity({Key key}) : super(key: key);
  @override
  AddNewCityState createState() => AddNewCityState();
}

class AddNewCityState extends State<AddNewCity> {
  var _newCitiesService = CitiesService();
  bool isLoading = false;
  @override
  void initState() {
    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    stateProvider.setCityList == false ? getAPICities() : Container();
    super.initState();
  }

  Future<String> getAPICities() async {
    var apiCities =
        await http.get('https://alpha.riyas.co.in/api/weather/cities/');
    var jsonData = json.decode(apiCities.body);

    final stateProvider = Provider.of<StateProvider>(context, listen: false);
    stateProvider.updateapiCitiesData(jsonData);
    return 'Success';
  }

  Future<dynamic> _addNewCitytoLocalDB(cityId) async {
    setState(() {
      isLoading = true;
    });
    final response =
        await http.get('https://alpha.riyas.co.in/api/weather/city/$cityId');
    var jsonData = json.decode(response.body);
    await _newCitiesService.addNewCity(
        jsonData['id'] + 3, jsonData['city'], jsonData['lat'], jsonData['lng']);
    setState(() {
      isLoading = false;
    });
    return 'Success';
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
            child: Container(
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
                        items: Provider.of<StateProvider>(context)
                            .apiCitiesData
                            .map((item) {
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
                        onChanged: Provider.of<StateProvider>(context)
                            .onChangeListCity,
                        value: Provider.of<StateProvider>(context)
                            .selectedListCity,
                      ),
                      RaisedButton(
                        onPressed: () => _addNewCitytoLocalDB(
                            Provider.of<StateProvider>(context, listen: false)
                                .selectedListCity),
                        textColor: Colors.white,
                        padding: const EdgeInsets.all(0.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                          ),
                          padding: const EdgeInsets.all(10.0),
                          child: const Text('Add City',
                              style: TextStyle(fontSize: 20)),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
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
                          child: Text("Adding City"),
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
