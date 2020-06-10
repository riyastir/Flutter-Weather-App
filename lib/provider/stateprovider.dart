import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class StateProvider extends ChangeNotifier {
  var selectedCity;
  int cityChange = 0;
  bool setCity = false;

  void onChangeCity(city) {
    selectedCity = city;
    cityChange = 1;
    setCity = true;
    notifyListeners();
  }

  void finishChange(){
    cityChange = 0;
    notifyListeners();
  }

  /*New City Page */
  List apiCitiesData = List();
  bool setCityList = false;
  var selectedListCity;

  void updateapiCitiesData(json){
    apiCitiesData = json;
    setCityList =  true;
    notifyListeners();
  }
  
  void onChangeListCity(city) {
    selectedListCity = city;
    notifyListeners();
  }

}
